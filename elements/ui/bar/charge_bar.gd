extends TextureProgressBar

@export_range(0.0, 100.0, 1.0) var charge: float = 0.0:
    set(value):
        charge = clamp(value, 0.0, 100.0)
        value = charge

func _ready() -> void:
    value = charge

func set_charge(amount: float) -> void:
    charge = clamp(amount, 0.0, 100.0)
    value = charge
