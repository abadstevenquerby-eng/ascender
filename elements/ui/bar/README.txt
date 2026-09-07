GODOT 4 CHARGE BAR

1. Copy charge_bar_background.png, charge_bar_fill.png,
   charge_bar.gd, and charge_bar.tscn into your Godot project's res:// folder.
2. Open charge_bar.tscn or instantiate it into your UI.
3. Change the charge with:
       $ChargeBar.set_charge(75)
   or:
       $ChargeBar.charge = 75

The bar uses the supplied pixel-art image as the visual base.
Nearest-neighbor filtering is used to keep the pixel-art look.
