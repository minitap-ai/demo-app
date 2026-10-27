"""Luigi's menu. Prices are whole euros so a voice agent can add them up reliably."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class MenuItem:
    id: str
    name: str
    category: str
    price: int
    ingredients: tuple[str, ...] = field(default_factory=tuple)


MENU: dict[str, MenuItem] = {
    item.id: item
    for item in (
        MenuItem("margherita", "Margherita", "pizza", 10, ("tomato", "mozzarella", "basil")),
        MenuItem("regina", "Regina", "pizza", 12, ("tomato", "mozzarella", "ham", "mushrooms")),
        MenuItem(
            "quattro_formaggi",
            "Quattro Formaggi",
            "pizza",
            13,
            ("mozzarella", "gorgonzola", "parmesan", "goat cheese"),
        ),
        MenuItem("diavola", "Diavola", "pizza", 13, ("tomato", "mozzarella", "spicy salami", "chili")),
        MenuItem(
            "vegetariana",
            "Vegetariana",
            "pizza",
            12,
            ("tomato", "mozzarella", "peppers", "zucchini", "olives"),
        ),
        MenuItem("calzone", "Calzone", "pizza", 14, ("tomato", "mozzarella", "ham", "egg")),
        MenuItem("tiramisu", "Tiramisu", "dessert", 6),
        MenuItem("coca_cola", "Coca-Cola 33cl", "drink", 3),
        MenuItem("san_pellegrino", "San Pellegrino 50cl", "drink", 4),
    )
}
