import logging
from datetime import datetime
from typing import Optional
from sqlalchemy.orm import Session
from app.models.models import AuditLog

logger = logging.getLogger("NutriCare.UU_PDP_Audit")

def log_pdp_access(
    db: Session,
    user_id: Optional[str],
    action: str,
    resource: str,
    ip_address: Optional[str] = None,
    details: Optional[str] = None
):
    """
    Mencatat log akses data kesehatan sensitif sesuai amanat UU No. 27/2022 tentang Pelindungan Data Pribadi (PDP).
    """
    try:
        log_entry = AuditLog(
            user_id=user_id,
            action=action,
            resource_accessed=resource,
            ip_address=ip_address or "127.0.0.1",
            details=details,
            timestamp=datetime.utcnow()
        )
        db.add(log_entry)
        db.commit()
        logger.info(f"[UU PDP AUDIT] User: {user_id} | Action: {action} | Resource: {resource}")
    except Exception as e:
        logger.error(f"Failed to record PDP audit log: {e}")
        db.rollback()
