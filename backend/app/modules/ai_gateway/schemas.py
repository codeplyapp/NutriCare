from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class ChatMessageRequest(BaseModel):
    message: str = Field(..., min_length=1)

class ChatMessageResponse(BaseModel):
    id: str
    sender: str
    message: str
    disclaimer: str
    should_escalate_to_doctor: bool
    escalation_reason: Optional[str] = None
    suggested_action_label: Optional[str] = None
    sent_at: datetime

class ChatHistoryItem(BaseModel):
    id: str
    sender: str
    message: str
    is_escalated: bool
    sent_at: datetime

class ChatHistoryResponse(BaseModel):
    messages: List[ChatHistoryItem]
