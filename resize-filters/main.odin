package ResizeFilters

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

    resize_filters := reflect.enum_fields_zipped(mgk.FilterType)

    // Remove Undefined/Sentinel filter
    resize_filters = resize_filters[1:len(resize_filters) - 1]
    
    image_info := mgk.AcquireImageInfo()
    defer mgk.DestroyImageInfo(image_info)

    image_info.filename = mgkh.string_to_magick_path(".\\input\\bill.webp")
    for filter_info in resize_filters {
        image := mgk.ReadImage(image_info, exc)
        mgkh.handle_exception(exc)

        filter := cast(mgk.FilterType)filter_info.value
        image = mgk.ResizeImage(image, 500, 500, filter, exc)
        mgkh.handle_exception(exc)

        path := strings.concatenate({".\\output\\", filter_info.name, ".png"})
        image.filename = mgkh.to_magick_path(path)
        delete(path)

        mgk.WriteImage(image_info, image, exc)
        mgkh.handle_exception(exc)

        mgk.DestroyImage(image)
    }
}