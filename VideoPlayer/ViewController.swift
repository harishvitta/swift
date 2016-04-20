//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Harish Vitta on 13/4/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var playerItem : AVPlayerItem!
    var inVisibleButton = UIButton()
    var timeObserver: AnyObject!
    var timeRemainingLabel : UILabel = UILabel()
    var seekSlider : UISlider = UISlider()
    var playRateBeforeSeek : Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.blackColor()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, atIndex: 0)
        
        //let url = NSURL(string: "http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8");
        
        let url = NSURL(string: "https://s3.amazonaws.com/adplayer/colgate.mp4")
        self.playerItem = AVPlayerItem(URL: url!)
        avPlayer.replaceCurrentItemWithPlayerItem(playerItem)

        view.addSubview(inVisibleButton)
        
        inVisibleButton.addTarget(self, action: #selector(ViewController.inVisibleButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let timeInterval : CMTime = CMTimeMake(1, 10)
        timeObserver = avPlayer.addPeriodicTimeObserverForInterval(timeInterval, queue: dispatch_get_main_queue(), usingBlock: { (elapsedTime : CMTime ) in
            
            //print(CMTimeGetSeconds(elapsedTime))
            self.observeTime(elapsedTime)
            
            
            
            
        })
        
        timeRemainingLabel.textColor = UIColor.whiteColor()
        view.addSubview(timeRemainingLabel);
        
        view.addSubview(seekSlider)
        
        seekSlider.addTarget(self, action: #selector(ViewController.sliderBeganTracking(_:)), forControlEvents: UIControlEvents.TouchDown)
        
        seekSlider.addTarget(self, action: #selector(ViewController.sliderEndedTracking(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        seekSlider.addTarget(self, action: #selector(ViewController.sliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateSlider(_:)), userInfo: nil, repeats: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play()
        
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        avPlayerLayer.frame = view.bounds
        inVisibleButton.frame = view.bounds
        
        let controlsHeight : CGFloat = 30
        
        let controlsY : CGFloat = view.bounds.size.height - controlsHeight
        
        timeRemainingLabel.frame = CGRect(x: 5, y: controlsY, width: 60, height: controlsHeight)
        
        seekSlider.frame = CGRect(x: timeRemainingLabel.frame.origin.x+timeRemainingLabel.bounds.size.width, y: controlsY, width: view.bounds.size.width - timeRemainingLabel.bounds.size.width, height: controlsHeight)
        
//        seekSlider.continuous = true
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeRight
    }
    
    func updateSlider(timer : NSTimer)
    {
        seekSlider.value = Float(CMTimeGetSeconds((avPlayer.currentItem?.currentTime())!))
        
    }
    
    func inVisibleButtonTapped(sender: UIButton!)
    {
        let playerIsPlayer : Bool = avPlayer.rate > 0
        if(playerIsPlayer)
        {
            avPlayer.pause()
        }
        else
        {
            avPlayer.play()
        }
    }
    
    func sliderBeganTracking(slider : UISlider!) {
        
        //print("sliderBeganTracking ::::")
        
        playRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
        
    }
    
    func sliderEndedTracking(slider : UISlider!) {
        
        //print("sliderEndedTracking ::::")
        //avPlayer.pause()

        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        
        updateTimeLabel(elapsedTime, duration: videoDuration)
        
        avPlayer.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 10)){
            (completed : Bool) -> Void in
            if(self.playRateBeforeSeek > 0)
            {
                self.avPlayer.play()
            }
        }

    }
    func sliderValueChanged(sender : UIControlEvents) {
        //avPlayer.pause()

        //print("sliderValueChanged :::::")
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        
        updateTimeLabel(elapsedTime, duration: videoDuration)
        
        self.seekSlider.maximumValue = Float(CMTimeGetSeconds(self.avPlayer.currentItem!.duration))
        self.seekSlider.minimumValue = 0;
        
    }
    
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64)
    {
        let timeRemaining: Float64 = CMTimeGetSeconds((avPlayer.currentItem?.duration)!) - elapsedTime
        
        timeRemainingLabel .text = String(format: "%02d:%02d", (lround(timeRemaining/60)%60), (lround(timeRemaining)%60))
        
        
        
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration);
        if (isfinite(duration)) {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime, duration: duration)
        }
    }
    
    deinit
    {
        avPlayer.removeTimeObserver(timeObserver)
    }

}

