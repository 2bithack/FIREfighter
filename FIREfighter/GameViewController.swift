//
//  GameViewController.swift
//  FIREfighter
//
//  Created by enzo bot on 6/29/16.
//  Copyright (c) 2016 GarbageGames. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate {

    var bannerView:GADBannerView!
    var interstitial:GADInterstitial!
    
    var didReceiveAd: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAds), name: NSNotification.Name(rawValue: "loadAds"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showInterstitial), name: NSNotification.Name(rawValue: "showInterstitial"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showAdsOnPause), name: NSNotification.Name(rawValue: "showAds"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.hideAds), name: NSNotification.Name(rawValue: "hideAds"), object: nil)
        
        if let scene = MainScene(fileNamed:"MainMenuScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }

    func loadAds(){
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.frame = CGRect(x: (view!.bounds.size.width - kGADAdSizeBanner.size.width) / 2, y: (view!.bounds.size.height - kGADAdSizeBanner.size.height) , width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
        bannerView.adUnitID = "ca-app-pub-5926587371750168/8644564331"
        bannerView.delegate = self
        bannerView.rootViewController = self
        view!.addSubview(bannerView)
        bannerView.isHidden = true
        let bannerRequest = GADRequest()
        let interstitialRequest = GADRequest()
        bannerRequest.testDevices = ["Simulator"]
        interstitialRequest.testDevices = ["Simulator"]
        
        bannerView.load(bannerRequest)
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-5926587371750168/6690153137")
        interstitial.load(interstitialRequest)
    }
    
    func hideAds(){
        bannerView.isHidden = true
    }
    
    func showInterstitial(){
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        didReceiveAd = false
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        didReceiveAd = true
    }
    
    func showAdsOnPause(){
        if didReceiveAd {
            bannerView.isHidden = false
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
