//
//  ViewController.swift
//  unixtime
//
//  Created by Paul on 12/01/2015.
//  Copyright (c) 2015 Paul. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController, ADBannerViewDelegate {
    
    @IBOutlet weak var adBannerView: ADBannerView!
    
    var time:timeval=timeval(tv_sec: 0, tv_usec: 0)
    var dohex:Bool=true
    var timer = NSTimer()

    @IBOutlet weak var autoManualValue: UISegmentedControl!
    
    @IBOutlet weak var hexDecValue: UISegmentedControl!
    
    @IBOutlet weak var tsTextField: UITextField!
    // @IBOutlet weak var usecTextField: UITextField!
    
    @IBOutlet weak var yearTextField: UITextField!
    
    @IBOutlet weak var monthTextField: UITextField!
    
    @IBOutlet weak var dayTextField: UITextField!
    
    @IBOutlet weak var minuteTextField: UITextField!
    
    @IBOutlet weak var secondTextField: UITextField!
    
    @IBOutlet weak var millisTextField: UITextField!
    
    @IBOutlet weak var hourTextField: UITextField!
    
    @IBAction func yearValueChanged(sender: AnyObject) {
    }
    
    @IBAction func monthValueChanged(sender: AnyObject) {
        println("it changed")
    }
    
  
    
    func populateNow () {
        
        var now=NSDate()
        var ti=now.timeIntervalSince1970;
        
        if dohex {
            tsTextField.text=String(format:"%x", time.tv_sec)
            //usecTextField.text=String(format:"%x", time.tv_usec)
        }
        else {
            tsTextField.text=String(format:"%d", time.tv_sec)
            //usecTextField.text=String(format:"%d", time.tv_usec)
            //var zz:Int = (Int)(ti)
            //usecTextField.text=String(format: "%d", zz)
        }
        let cal=NSCalendar.currentCalendar()
        let comp=cal.components((.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit), fromDate:now)
            
        yearTextField.text=String(format: "%04d",comp.year)
        monthTextField.text=String(comp.month)
        dayTextField.text=String(comp.day)
        hourTextField.text=String(format: "%02d",comp.hour)
        minuteTextField.text=String(format: "%02d",comp.minute)
        secondTextField.text=String(format: "%02d", comp.second)
        
    }
    
    @IBAction func nowButton(sender: AnyObject) {
        gettimeofday(&time, nil)
        populateNow()
    }
    
    @IBOutlet weak var nowButton: UIButton!
    
    @IBAction func autoManualSelect(sender: AnyObject) {
        if autoManualValue.selectedSegmentIndex == 0 {
            // manual update
            timer.invalidate()
            nowButton.enabled=true
        }
        else {
            // auto update
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updTime"), userInfo: nil, repeats: true)
            nowButton.enabled=false
        }
        populateNow()
        
    }
    
    func updTime()  {
        
        gettimeofday(&time, nil)
        
        populateNow()
        
    }
    
    @IBAction func hexDecSelect(sender: AnyObject) {
        if hexDecValue.selectedSegmentIndex == 0 {
            dohex=true
        }
        else {
            dohex=false
        }
        populateNow()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.canDisplayBannerAds=true
        self.adBannerView.delegate=self
        self.adBannerView.hidden=true
        
        // Do any additional setup after loading the view, typically from a nib.

        populateNow()
        
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        NSLog("bannerViewWillLoadAd")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        NSLog("bannerViewDidLoadAd")
        self.adBannerView.hidden=false
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        NSLog("bannerViewDidLoadAd")
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        
        // optional pause
        
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiverAdWithError error: NSError!) {
        NSLog("bannerView")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

