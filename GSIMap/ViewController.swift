//
//  ViewController.swift
//  GSIMap
//
//  Created by tasshy on 2020/07/26.
//  Copyright © 2020 tasshy. All rights reserved.
//  https://qiita.com/imk2o/items/7328ee15e248ed3ff6f2

import UIKit
import MapKit

class ViewController: UIViewController {
    private let mapView = MKMapView()

    private let buttonSize: CGFloat = 40
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    private lazy var zoomInButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.imageWithColor(UIColor.black.withAlphaComponent(0.7)), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = buttonSize / 2
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "plus.magnifyingglass", withConfiguration: symbolConfiguration), for: .normal)
        button.addTarget(self, action: #selector(zoomInAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var zoomOutButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.imageWithColor(UIColor.black.withAlphaComponent(0.7)), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = buttonSize / 2
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "minus.magnifyingglass", withConfiguration: symbolConfiguration), for: .normal)
        button.addTarget(self, action: #selector(zoomOutAction(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.addOverlay(GSITile.ortho.tileOverlay, level: .aboveLabels)
        view.addSubview(mapView)
        
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        mapView.frame = view.bounds
        
        let bottom = view.bounds.maxY - view.safeAreaInsets.bottom
        let right = view.bounds.maxX - view.safeAreaInsets.right
        zoomOutButton.frame = CGRect(x: right - 50, y: bottom - 80, width: buttonSize, height: buttonSize)
        zoomInButton.frame  = CGRect(x: right - 50, y: zoomOutButton.frame.minY - 50, width: buttonSize, height: buttonSize)
    }
    
    @IBAction private func zoomInAction(_ sender: UIButton) {
        mapView.setCenter(mapView.centerCoordinate, zoomLevel: mapView.zoomLevel + 1, animated: true)
    }
    
    @IBAction private func zoomOutAction(_ sender: UIButton) {
        mapView.setCenter(mapView.centerCoordinate, zoomLevel: mapView.zoomLevel - 1, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        MKTileOverlayRenderer(overlay: overlay)
    }
}
