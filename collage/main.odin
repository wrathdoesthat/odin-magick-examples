package Collage

import mgk "../odin-magick"
import mgkh "../odin-magick/helpers"

import "core:strings"
import os "core:os/os2"
import "core:fmt"
import "core:c"
import "core:mem"

main :: proc() {
    mgk.MagickCoreGenesis(strings.unsafe_string_to_cstring(os.args[0]), .MagickFalse) 
    defer mgk.MagickCoreTerminus()

    exc := mgk.AcquireExceptionInfo()
    defer mgk.DestroyExceptionInfo(exc)

    cached_image_info := mgk.AcquireImageInfo()
    defer mgk.DestroyImageInfo(cached_image_info)

    // Reused for collage images
    image_info := mgk.AcquireImageInfo()
    defer mgk.DestroyImageInfo(image_info)

    images : [9]^mgk.Image
    num_images := 0

    image_walker := os.walker_create(".\\input")
    for fi in os.walker_walk(&image_walker) {
        image_info.filename = mgkh.string_to_magick_path(fi.fullpath) 
        image := mgk.ReadImage(image_info, exc)
        mgkh.handle_exception(exc)

        image = mgk.ResizeImage(image, 500, 500, .MitchellFilter, exc)
        mgkh.handle_exception(exc)

        images[num_images] = image
        
        num_images += 1
        if num_images == 9 do break
    }
    os.walker_destroy(&image_walker)

    background_info := mgk.AcquireImageInfo()
    defer mgk.DestroyImageInfo(background_info)

    background_pixel := new(mgk.PixelInfo)
    defer free(background_pixel)

    // Make background transparent
    background_pixel.alpha_trait = .BlendPixelTrait
    background_pixel.alpha = 0

    image_size := [2]c.size_t{500, 500}
    collage_size := (image_size * 3)

    background := mgk.NewMagickImage(background_info, collage_size.x, collage_size.y, background_pixel, exc)
    mgkh.handle_exception(exc)

    for image, i in images {
        row := c.ssize_t(i / 3);
        col := c.ssize_t(i % 3);
        x_offset := col * c.ssize_t(image_size.x);
        y_offset := row * c.ssize_t(image_size.y);

        mgk.CompositeImage(background, image, .CopyCompositeOp, .MagickTrue, x_offset, y_offset, exc);
        mgkh.handle_exception(exc)

        mgk.DestroyImage(image)
    }

    background.filename = mgkh.string_to_magick_path(".\\output\\canvas.png")
    mgk.WriteImage(image_info, background, exc)
    mgkh.handle_exception(exc)
}