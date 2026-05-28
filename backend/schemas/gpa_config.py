from pydantic import BaseModel, validator


class GpaConfigUpdate(BaseModel):
    prelim_pct: int
    midterm_pct: int
    finals_pct: int

    @validator('finals_pct')
    def weights_must_sum_100(cls, v, values):
        total = values.get('prelim_pct', 0) + values.get('midterm_pct', 0) + v
        if total != 100:
            raise ValueError(f'Weights must sum to 100, got {total}')
        return v
