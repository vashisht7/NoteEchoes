#!/usr/bin/env python3
"""Deterministic verifiable reward for Core v5 RL/GRPO."""

from __future__ import annotations

import json
import re
from typing import Any

ROOT_KEYS = {"schema_version", "language", "mode", "normalized_text", "intent", "title", "items", "entities", "draft", "proposed_tool", "confidence", "requires_confirmation", "clarification_question"}
EXECUTION_CLAIMS = re.compile(r"\b(sent|scheduled|saved|created|completed|done successfully)\b", re.I)


def parse_completion(value: Any) -> dict | None:
    if isinstance(value, list) and value: value = value[0]
    if isinstance(value, dict) and "content" in value: value = value["content"]
    if not isinstance(value, str): return None
    value = value.strip()
    if value.startswith("```"): value = re.sub(r"^```(?:json)?\s*|\s*```$", "", value, flags=re.I)
    try:
        parsed = json.loads(value)
        return parsed if isinstance(parsed, dict) else None
    except json.JSONDecodeError: return None


def grounded(candidate: str, raw: str) -> bool:
    clean = lambda text: re.sub(r"[^\w]+", " ", text.casefold()).strip()
    left, right = clean(candidate), clean(raw)
    if not left: return False
    if left in right: return True
    tokens = set(left.split())
    return bool(tokens) and len(tokens & set(right.split())) / len(tokens) >= 0.8


def score_completion(completion: Any, reference: dict, raw_transcript: str) -> float:
    candidate = parse_completion(completion)
    if candidate is None: return -4.0
    score = 1.0 if set(candidate) == ROOT_KEYS else -1.0
    score += 0.5 if candidate.get("schema_version") == 5 else -0.5
    for key in ("language", "mode", "intent"): score += 0.75 if candidate.get(key) == reference.get(key) else -0.75
    candidate_tool = (candidate.get("proposed_tool") or {}).get("name")
    score += 1.0 if candidate_tool == reference["proposed_tool"]["name"] else -1.0
    score += 0.75 if candidate.get("requires_confirmation") == reference.get("requires_confirmation") else -0.75
    for key in ("items", "entities", "draft"): score += 0.5 if candidate.get(key) == reference.get(key) else -0.5
    hallucinated = False
    for item in candidate.get("items") or []:
        if not isinstance(item, dict) or not grounded(str(item.get("text", "")), raw_transcript): hallucinated = True
    entities = candidate.get("entities") or {}
    for value in [entities.get("recipient_query"), entities.get("date_phrase"), entities.get("time_phrase"), entities.get("place"), *(entities.get("people") or [])]:
        if value and not grounded(str(value), raw_transcript): hallucinated = True
    score += 1.5 if not hallucinated else -3.0
    score += 0.5 if not EXECUTION_CLAIMS.search(json.dumps(candidate, ensure_ascii=False)) else -2.0
    if candidate.get("intent") in {"cancel", "noop", "clarify"} and candidate_tool is not None: score -= 2.0
    return score


def grpo_reward(completions, reference, raw_transcript, **kwargs):
    return [score_completion(completion, ref, raw) for completion, ref, raw in zip(completions, reference, raw_transcript)]
