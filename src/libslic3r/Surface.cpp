#include "BoundingBox.hpp"
#include "Surface.hpp"
#include "SVG.hpp"

namespace Slic3r {

BoundingBox get_extents(const Surface &surface)
{
    return get_extents(surface.expolygon.contour);
}

BoundingBox get_extents(const Surfaces &surfaces)
{
    BoundingBox bbox;
    if (! surfaces.empty()) {
        bbox = get_extents(surfaces.front());
        for (size_t i = 1; i < surfaces.size(); ++ i)
            bbox.merge(get_extents(surfaces[i]));
    }
    return bbox;
}

BoundingBox get_extents(const SurfacesPtr &surfaces)
{
    BoundingBox bbox;
    if (! surfaces.empty()) {
        bbox = get_extents(*surfaces.front());
        for (size_t i = 1; i < surfaces.size(); ++ i)
            bbox.merge(get_extents(*surfaces[i]));
    }
    return bbox;
}

const char* surface_type_to_color_name(const SurfaceType surface_type)
{
    switch (surface_type) {
        case stTop:             return "rgb(218,52,144)"; // "red"; // categorical 8
        case stBottom:          return "rgb(71,226,111)"; // "green"; // categorical 12
        case stBottomBridge:    return "rgb(39,128,235)"; // "blue"; // categorical 3
        case stInternal:        return "rgb(223,191,25)"; // yellow  // categorical 1
        case stInternalSolid:   return "rgb(111,56,177)"; // magenta // categorical 4
        case stInternalBridge:  return "rgb(25,192,199)"; // cyan // categorical 11
        case stInternalVoid:    return "rgb(128,128,128)"; // 50% neutral
        case stPerimeter:       return "rgb(232,135,26)"; // maroon // categorical 2
        default:                return "rgb(64,64,64)"; // 25% black
    };
}

Point export_surface_type_legend_to_svg_box_size()
{
    return Point(scale_(1.+10.*8.), scale_(3.)); 
}

void export_surface_type_legend_to_svg(SVG &svg, const Point &pos)
{
    // 1st row
    coord_t pos_x0 = pos(0) + scale_(1.);
    coord_t pos_x = pos_x0;
    coord_t pos_y = pos(1) + scale_(1.5);
    coord_t step_x = scale_(10.);
    svg.draw_legend(Point(pos_x, pos_y), "perimeter"      , surface_type_to_color_name(stPerimeter));
    pos_x += step_x;
    svg.draw_legend(Point(pos_x, pos_y), "top"            , surface_type_to_color_name(stTop));
    pos_x += step_x;
    svg.draw_legend(Point(pos_x, pos_y), "bottom"         , surface_type_to_color_name(stBottom));
    pos_x += step_x;
    svg.draw_legend(Point(pos_x, pos_y), "bottom bridge"  , surface_type_to_color_name(stBottomBridge));
    pos_x += step_x;
    svg.draw_legend(Point(pos_x, pos_y), "invalid"        , surface_type_to_color_name(SurfaceType(-1)));
    // 2nd row
    pos_x = pos_x0;
    pos_y = pos(1)+scale_(2.8);
    svg.draw_legend(Point(pos_x, pos_y), "internal"       , surface_type_to_color_name(stInternal));
    pos_x += step_x;
    svg.draw_legend(Point(pos_x, pos_y), "internal solid" , surface_type_to_color_name(stInternalSolid));
    pos_x += step_x;
    svg.draw_legend(Point(pos_x, pos_y), "internal bridge", surface_type_to_color_name(stInternalBridge));
    pos_x += step_x;
    svg.draw_legend(Point(pos_x, pos_y), "internal void"  , surface_type_to_color_name(stInternalVoid));
}

bool export_to_svg(const char *path, const Surfaces &surfaces, const float transparency)
{
    BoundingBox bbox;
    for (Surfaces::const_iterator surface = surfaces.begin(); surface != surfaces.end(); ++surface)
        bbox.merge(get_extents(surface->expolygon));

    SVG svg(path, bbox);
    for (Surfaces::const_iterator surface = surfaces.begin(); surface != surfaces.end(); ++surface)
        svg.draw(surface->expolygon, surface_type_to_color_name(surface->surface_type), transparency);
    svg.Close();
    return true;
}

}
