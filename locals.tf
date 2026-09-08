locals {
  # Single source of truth for the hierarchical policy count guard, so the
  # policy and its rule can never disagree about whether index [0] exists.
  create_hierarchical = var.parent != ""
}
