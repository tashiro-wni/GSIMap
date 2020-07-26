//
//  MKMapView+ZoomLevel.swift
//  GSIMap
//
//  Created by tasshy on 2020/07/26.
//  Copyright © 2020 tasshy. All rights reserved.
//

import MapKit

private let kMercatorOffset: Double = 268435456
private let kMercatorRadius: Double = 85445659.44705395

extension MKMapView {
    var zoomLevel: UInt {
        let mapWidthInPixels = Double(bounds.width * 2)  // 2: retina
        guard mapWidthInPixels > 0 else { return 0 }
        
        let zoomScale = region.span.longitudeDelta * kMercatorRadius * Double.pi / (180 * mapWidthInPixels)
        return UInt(round(max(19.0 - log2(zoomScale), 0)) + 1)
    }
    
    func setCenter(_ coordinate: CLLocationCoordinate2D, zoomLevel: UInt, animated: Bool) {
        var zoomLevel = zoomLevel
        zoomLevel -= 1 //なぜか１つあげないと合わない
        zoomLevel = min(zoomLevel, 28)
        
        // use the zoom level to compute the region
        let span = coordinateSpan(self, centerCoordinate: coordinate, zoomLevel: zoomLevel)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        // set the region like normal
        setRegion(region, animated: animated)
    }
    
    // MARK: - private method
    private func longitudeToPixelSpaceX(_ longitude: CLLocationDegrees) -> Double {
        round(kMercatorOffset + kMercatorRadius * longitude * Double.pi / 180)
    }
    
    private func latitudeToPixelSpaceY(_ latitude: CLLocationDegrees) -> Double {
        // latitude = ±90.0 の場合、無限大になる
        round(kMercatorOffset - kMercatorRadius * log((1.0 + sin(latitude * Double.pi / 180)) / (1.0 - sin(latitude * Double.pi / 180))) / 2.0)
    }
    
    private func pixelSpaceXToLongitude(_ pixelX: Double) -> CLLocationDegrees {
        ((round(pixelX) - kMercatorOffset) / kMercatorRadius) * 180 / Double.pi
    }
    
    private func pixelSpaceYToLatitude(_ pixelY: Double) -> CLLocationDegrees {
        (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - kMercatorOffset) / kMercatorRadius))) * 180 / Double.pi
    }
    
    private func coordinateSpan(_ mapView: MKMapView, centerCoordinate: CLLocationCoordinate2D, zoomLevel: UInt) -> MKCoordinateSpan {
        // convert center coordiate to pixel space
        let centerPixelX = longitudeToPixelSpaceX(centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(centerCoordinate.latitude)

        // determine the scale value from the zoom level
        let zoomExponent = Int(20 - zoomLevel)
        let zoomScale = CGFloat(truncating: pow(2, zoomExponent) as NSNumber)
        
        // scale the map’s size in pixel space
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth  = Double(mapSizeInPixels.width * zoomScale)
        let scaledMapHeight = Double(mapSizeInPixels.height * zoomScale)
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
        
        // find delta between left and right longitudes
        let minLng = pixelSpaceXToLongitude(topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        // find delta between top and bottom latitudes
        let minLat = pixelSpaceYToLatitude(topLeftPixelY)
        let maxLat = pixelSpaceYToLatitude(topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)
        
        // create and return the lat/lng span
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}
