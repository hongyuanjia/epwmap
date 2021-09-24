#' Show free available EPW sources using Mapbox
#'
#' @importFrom mapboxer mapboxer
#' @importFrom eplusr read_epw
#' @export
#' @examples
#' \dontrun{
#' epwmap()
#' }
epwmap <- function() {
    db <- getFromNamespace("WEATHER_DB", "eplusr")

    map <- mapboxer::as_mapbox_source(db, lng = "longitude", lat = "latitude")
    map <- mapboxer::mapboxer(map, style = mapboxer::basemaps$Carto$positron,
        token = "pk.eyJ1IjoiaG9uZ3l1YW5qaWEiLCJhIjoiY2t0eG5vNnUzMnZnMjJ2cG16dTlqa29oNiJ9.Ms783VAJopS7K7ST8M1s-Q"
    )
    map <- mapboxer::add_navigation_control(map, pos = "top-left", showCompass = TRUE)
    map <- mapboxer::add_fullscreen_control(map)
    map <- mapboxer::add_scale_control(map, unit = "nautical")
    map <- mapboxer::add_control(map,
        "GeolocateControl",
        trackUserLocation = TRUE,
        positionOptions = list(enableHighAccuracy = TRUE)
    )

    map <- mapboxer::add_circle_layer(
        map,
        circle_color = "navy",
        circle_opacity = 0.5,
        popup = '
            <table>
                <tbody>
                    <tr>
                        <th style="text-align:right">Country</th>
                        <td style="text-align:left">{{country}}</td>
                    </tr>
                    <tr>
                        <th style="text-align:right">State/Province</th>
                        <td style="text-align:left">{{state_province}}</td>
                    </tr>
                    <tr>
                        <th style="text-align:right">Location</th>
                        <td style="text-align:left">{{location}}</td>
                    </tr>
                    <tr>
                        <th style="text-align:right">WMO Number</th>
                        <td style="text-align:left">{{wmo_number}}</td>
                    </tr>
                    <tr>
                        <th style="text-align:right">Source Type</th>
                        <td style="text-align:left">{{source_type}}</td>
                    </tr>
                    <tr>
                        <th style="text-align:right">Provider</th>
                        <td style="text-align:left"><a href="https://{{provider}}/weather">{{provider}}</a></td>
                    </tr>
                    <tr>
                        <th style="text-align:right">Data</th>
                        <td style="text-align:left"><a href="{{zip_url}}">Download</a></td>
                    </tr>
                </tbody>
            </table>
            '
    )

    add_geocoder(map)
}

#' @importFrom htmlwidgets onRender
add_geocoder <- function(map) {
    geocoder_plugin <- htmltools::htmlDependency(
        name = "geocoder",
        version = "4.7.2",
        src = c(href = "https://api.mapbox.com/mapbox-gl-js/plugins/mapbox-gl-geocoder/v4.7.2"),
        script = "mapbox-gl-geocoder.min.js",
        stylesheet = "mapbox-gl-geocoder.css"
    )

    map$dependencies <- c(map$dependencies, list(geocoder_plugin))

    htmlwidgets::onRender(map,
        "function(el, x) {
           const map = mapboxer._widget[el.id].map;
           const geocoder = new MapboxGeocoder({
               accessToken: mapboxgl.accessToken,
               mapboxgl: mapboxgl
           });
           map.addControl(geocoder);
        }"
    )
}
