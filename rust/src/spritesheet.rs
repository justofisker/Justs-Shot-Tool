use godot::classes::FileAccess;
use godot::prelude::*;

extern crate flatbuffers;

#[allow(dead_code, unused_imports)]
#[path = "./spritesheetf_generated.rs"]
mod spritesheetf_generated;
use spritesheetf_generated as SpriteFile;
use spritesheetf_generated::root_as_sprite_sheet_root;

#[derive(GodotClass)]
#[class(no_init, base=Resource)]
struct SpriteSheetDeserializer {
    #[var]
    sprite_sheets: Array<Gd<RotmgSpriteSheet>>,
    #[var]
    animated_sprites: Array<Gd<RotmgAnimatedSprite>>,
    base: Base<Resource>,
}

#[godot_api]
impl SpriteSheetDeserializer {
    #[func]
    fn open(file: GString) -> Option<Gd<Self>> {
        if FileAccess::file_exists(&file) {
            if let Ok(sprite_sheet_root) =
                root_as_sprite_sheet_root(FileAccess::get_file_as_bytes(&file).as_slice())
            {
                let mut animated_sprites = array![];
                for animated_sprite in sprite_sheet_root.animated_sprites().unwrap() {
                    animated_sprites.push(&RotmgAnimatedSprite::from_file(&animated_sprite))
                }
                let mut sprite_sheets = array![];
                for sprite_sheet in sprite_sheet_root.sprites().unwrap() {
                    sprite_sheets.push(&RotmgSpriteSheet::from_file(&sprite_sheet))
                }
                return Some(Gd::from_init_fn(|base| Self {
                    sprite_sheets,
                    animated_sprites,
                    base,
                }));
            }
        }
        None
    }
}

impl Into<Rect2> for &SpriteFile::Position {
    fn into(self) -> Rect2 {
        Rect2 {
            position: Vector2 {
                x: self.x(),
                y: self.y(),
            },
            size: Vector2 {
                x: self.w(),
                y: self.h(),
            },
        }
    }
}

impl Into<Color> for &SpriteFile::Color {
    fn into(self) -> Color {
        Color {
            r: self.r(),
            g: self.g(),
            b: self.b(),
            a: self.a(),
        }
    }
}

#[derive(GodotClass)]
#[class(no_init, base=Resource)]
struct RotmgSprite {
    #[var]
    position: Rect2,
    #[var]
    mask_position: Rect2,
    #[var]
    padding: u16,
    #[var]
    index: u16,
    #[var]
    most_common_color: Color,
    #[var]
    is_t: bool,
    #[var]
    sprite_sheet_name: GString,
    #[var]
    a_id: i64,
    base: Base<Resource>,
}

impl RotmgSprite {
    fn from_file(sprite: &SpriteFile::Sprite) -> Gd<Self> {
        Gd::from_init_fn(|base| Self {
            position: sprite.position().unwrap().into(),
            mask_position: sprite.mask_position().unwrap().into(),
            padding: sprite.padding(),
            index: sprite.index(),
            most_common_color: sprite.most_common_color().unwrap().into(),
            is_t: sprite.is_t(),
            sprite_sheet_name: sprite.sprite_sheet_name().unwrap().into(),
            a_id: sprite.a_id() as i64,
            base,
        })
    }
}

#[derive(GodotClass)]
#[class(no_init, base=Resource)]
struct RotmgSpriteSheet {
    #[var]
    sprite_sheet_name: GString,
    #[var]
    atlas_id: i64,
    #[var]
    sprites: Array<Gd<RotmgSprite>>,
    base: Base<Resource>,
}

impl RotmgSpriteSheet {
    fn from_file(sprite_sheet: &SpriteFile::SpriteSheet) -> Gd<Self> {
        let mut sprites = array![];

        for sprite in sprite_sheet.sprites().unwrap() {
            sprites.push(&RotmgSprite::from_file(&sprite));
        }

        Gd::from_init_fn(|base| Self {
            sprite_sheet_name: sprite_sheet.sprite_sheet_name().unwrap().into(),
            atlas_id: sprite_sheet.atlas_id() as i64,
            sprites: sprites,
            base,
        })
    }
}

#[derive(GodotClass)]
#[class(no_init, base=Resource)]
struct RotmgAnimatedSprite {
    #[var]
    sprite_sheet_name: GString,
    #[var]
    index: u16,
    #[var]
    set: u16,
    #[var]
    direction: u16,
    #[var]
    action: u16,
    #[var]
    sprite: Gd<RotmgSprite>,
    base: Base<Resource>,
}

impl RotmgAnimatedSprite {
    fn from_file(animated_sprite: &SpriteFile::AnimatedSprite) -> Gd<Self> {
        Gd::from_init_fn(|base| Self {
            sprite_sheet_name: animated_sprite.sprite_sheet_name().unwrap().into(),
            index: animated_sprite.index(),
            set: animated_sprite.index(),
            direction: animated_sprite.direction(),
            action: animated_sprite.action(),
            sprite: RotmgSprite::from_file(&animated_sprite.sprite().unwrap()),
            base,
        })
    }
}
