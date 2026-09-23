from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class NotificationSendRequest(BaseModel):
    user_id: str
    title: str
    body: str
    category: str = "reminder"
    target: str = "app"  # app, watch, both

class NotificationSendResponse(BaseModel):
    status: str
    delivered_to: str
    timestamp: datetime
