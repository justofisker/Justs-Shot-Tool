use godot::prelude::*;

struct SpriteTools;

mod spritesheet;

#[gdextension]
unsafe impl ExtensionLibrary for SpriteTools {}
