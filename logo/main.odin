package logo 

/*
    translation of first example from https://imagemagick.org/script/magick-core.php
    it is sort of weird to loop through every frame of the gif to make a single image thumbnail though
*/

import mgk "../odin-magick"
import mgkh "../odin-magick/helpers"

import "core:strings"
import os "core:os/os2"
import "core:reflect"
import "core:fmt"

main :: proc() {
    mgk.MagickCoreGenesis(strings.unsafe_string_to_cstring(os.args[0]), .MagickFalse)
    defer mgk.MagickCoreTerminus()

    exc := mgk.AcquireExceptionInfo()
    defer mgk.DestroyExceptionInfo(exc)

    image_info := mgk.AcquireImageInfo()
    defer mgk.DestroyImageInfo(image_info)

    image_info.filename = mgkh.string_to_magick_path(".\\input\\hyrax.gif")
    images := mgk.ReadImage(image_info, exc)
    mgkh.handle_exception(exc)

    thumbnails := mgk.NewImageList()
    defer mgk.DestroyImageList(thumbnails)

    for {
        image := mgk.RemoveFirstImageFromList(&images)
        if image == nil do break

        resize_image := mgk.ResizeImage(image, 106, 80, .LanczosFilter, exc)
        mgkh.handle_exception(exc)

        mgk.AppendImageToList(&thumbnails, resize_image)
        mgk.DestroyImage(image)
    }

    thumbnails.filename = mgkh.string_to_magick_path(".\\output\\thumbs.png")
    mgk.WriteImage(image_info, thumbnails, exc)
    mgkh.handle_exception(exc)
}   