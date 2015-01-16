//
//  ViewController.swift
//  unixtime
//
//  Created by Paul on 12/01/2015.
//  Copyright (c) 2015 Paul. All rights reserved.
//

import UIKit
import iAd
import Foundation

class ViewController: UIViewController, ADBannerViewDelegate {
    
    @IBOutlet weak var adBannerView: ADBannerView!
    
    var dateEdited=false
    var tsEdited=false
    
    var time:timeval=timeval(tv_sec: 0, tv_usec: 0)
    var dohex:Bool=false
//    var doUTC:Bool=true
    var timer = NSTimer()

    @IBOutlet weak var errorText: UILabel!
    
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
    
    @IBOutlet weak var recalcButton: UIButton!
    
    func populateFromDate() {
        var dateValid:Bool=true
        
        var ds : String = yearTextField.text+"-"+monthTextField.text+"-"+dayTextField.text+" "+hourTextField.text+":"+minuteTextField.text+":"+secondTextField.text
        NSLog(ds)
        
        self.view.endEditing(true)
        
        if (yearTextField.text.isEmpty || yearTextField.text.toInt() < 1970 || yearTextField.text.toInt() > 2038) {
            dateValid=false;
            errorText.text="Year out of range 1970-2038"
        }
        else {
            if (monthTextField.text.isEmpty || monthTextField.text.toInt() < 1 || monthTextField.text.toInt() > 12) {
                dateValid=false;
                errorText.text="Month out of range 1-12"
            }
            else {
                if (dayTextField.text.isEmpty || dayTextField.text.toInt() < 1 || dayTextField.text.toInt() > 31) {
                    dateValid=false;
                    errorText.text="Day out of range"
                }
                else {
                    if (hourTextField.text.isEmpty || hourTextField.text.toInt() < 0 || hourTextField.text.toInt() > 23) {
                        dateValid=false;
                        errorText.text="Hour out of range 0-23"
                    }
                    else {
                        if (minuteTextField.text.isEmpty || minuteTextField.text.toInt() < 0 || minuteTextField.text.toInt() > 59) {
                            dateValid=false;
                            errorText.text="Minute out of range 0-59"
                        }
                        else {
                            if (secondTextField.text.isEmpty || secondTextField.text.toInt() < 0 || secondTextField.text.toInt() > 59) {
                                dateValid=false;
                                errorText.text="Second out of range 0-59"
                            }
                        }
                    }
                }
            }
        }
        
        if (dateValid) {
            var dateFormatter = NSDateFormatter()
            /*
            if (doUTC) {
            var timeZone=NSTimeZone(abbreviation:"UTC")
            dateFormatter.timeZone=timeZone
            }
            */
            
            dateFormatter.dateFormat = "yyyy-M-d H:m:s"
            
            // convert string into date
            
            var nw:NSDate? = dateFormatter.dateFromString(ds)
            // hack - fix populateNow
            if (nw != nil) {
                var nowf:NSDate=nw!
                var nti=nowf.timeIntervalSince1970
                if (nti > Double(0x7fffffff) || nti < 0) {
                    errorText.text="Date out of UNIX TS Range"
                }
                else {
                NSLog("%f", nowf.timeIntervalSince1970)
                var now:Int=Int(nowf.timeIntervalSince1970)
                
                if dohex {
                    tsTextField.text=String(format:"%x", now)
                }
                else {
                    tsTextField.text=String(format:"%u", now)
                }
                
                errorText.text=""
                
                self.view.endEditing(true)
                }
            }
            else {
                // it's invalid
                errorText.text="Invalid date entered-check MM/DD"
            }
        }
    }
    
    @IBAction func recalcButton(sender: AnyObject) {
        
        if (dateEdited) {
            populateFromDate()
        }
        else {
            // TS must have been edited most recently
            // validate
            if (!tsTextField.text.isEmpty) {
                var now:NSDate
                if (!dohex) {
                    if tsTextField.text.toInt() != nil {
                        var tsvi=tsTextField.text.toInt()!
                        if (tsvi < 0 || tsvi > Int(INT_MAX)) {
                            errorText.text="Valid TS values in Decimal mode are 0 to "+String(INT_MAX)
                            self.view.endEditing(true)
                        }
                        else {
                            var tsv:NSTimeInterval=NSTimeInterval(tsvi)
                            now=NSDate(timeIntervalSince1970: tsv)
                            populateDisplay(Int(tsv), now:now)
                            self.view.endEditing(true)
                        }
                    }
                    else {
                        errorText.text="TS out of 0 to "+String(INT_MAX)+" range"
                        self.view.endEditing(true)
                    }
                }
                else {
                    // hex validation
                    var scanner=NSScanner(string: tsTextField.text)
                    var result : UInt32 = 0
                    if scanner.scanHexInt(&result) {
                        if (result > 0x7fffffff) {
                            errorText.text="TS out of 0 to 0x7fffffff range"
                            self.view.endEditing(true)
                        }
                        else {
                            var tsv:NSTimeInterval=NSTimeInterval(result)
                            now=NSDate(timeIntervalSince1970: tsv)
                            populateDisplay(Int(tsv), now:now)
                            self.view.endEditing(true)
                        }
                    }
                    else {
                        errorText.text="TS out of 0 to 0x7fffffff range"
                        self.view.endEditing(true)
                    }
                }
            }
        }
    }
    
    func setDateEdited () {
        dateEdited=true
        tsEdited=false
        recalcButton.setTitle("Date->TS", forState: UIControlState.Normal)
        tsTextField.text=""
    }

    @IBAction func tsValueChanged(sender: AnyObject) {
        NSLog("ts value change")
        tsEdited=true
        dateEdited=false
        recalcButton.setTitle("TS->Date", forState: UIControlState.Normal)
        yearTextField.text=""
        monthTextField.text=""
        dayTextField.text=""
        hourTextField.text=""
        minuteTextField.text=""
        secondTextField.text=""
    }
    
    @IBAction func yearChanged(sender: AnyObject) {
        NSLog("year changed")
        setDateEdited()
    }
    
    @IBAction func monthChanged(sender: AnyObject) {
        setDateEdited()
    }
    
    @IBAction func dayChanged(sender: AnyObject) {
        setDateEdited()
    }
    
    @IBAction func hourChanged(sender: AnyObject) {
        setDateEdited()
    }
    
    @IBAction func minuteChanged(sender: AnyObject) {
        setDateEdited()
    }
    
    @IBAction func secondChanged(sender: AnyObject) {
        setDateEdited()
    }
    
    func populateFromTS(currFormatIsHex:Bool) {
        if (!currFormatIsHex) {
            if tsTextField.text.toInt() != nil {
                var tsvi=tsTextField.text.toInt()!
                if (tsvi < 0 || tsvi > Int(INT_MAX)) {
                    tsTextField.text=""
                    self.view.endEditing(true)
                }
                else {
                    var tsv:NSTimeInterval=NSTimeInterval(tsvi)
                    var now=NSDate(timeIntervalSince1970: tsv)
                    populateDisplay(Int(tsv), now:now)
                    self.view.endEditing(true)
                }
            }
            else {
                tsTextField.text=""
                self.view.endEditing(true)
            }
        }
        else {
            // hex validation
            var scanner=NSScanner(string: tsTextField.text)
            var result : UInt32 = 0
            if scanner.scanHexInt(&result) {
                if (result > 0x7fffffff) {
                    tsTextField.text=""
                    self.view.endEditing(true)
                }
                else {
                    var tsv:NSTimeInterval=NSTimeInterval(result)
                    var now:NSDate
                    now=NSDate(timeIntervalSince1970: tsv)
                    populateDisplay(Int(tsv), now:now)
                    self.view.endEditing(true)
                }
            }
            else {
                tsTextField.text=""
                self.view.endEditing(true)
            }
        }
    }
    
    func populateNow () {
        
        var now=NSDate()
        var tif=now.timeIntervalSince1970;
        NSLog("populateNow %f", tif)
        var ti:Int=Int(tif)
        populateDisplay(ti, now:now)
    }
    
    func populateDisplay(var ti:Int, var now:NSDate) {
        if dohex {
            tsTextField.text=String(format:"%x", ti)
        }
        else {
            tsTextField.text=String(format:"%u", ti)
        }
        let cal=NSCalendar.currentCalendar()
        let comp=cal.components((.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit), fromDate:now)
            
        yearTextField.text=String(format: "%04d",comp.year)
        monthTextField.text=String(format: "%02d", comp.month)
        dayTextField.text=String(format: "%02d", comp.day)
        hourTextField.text=String(format: "%02d",comp.hour)
        minuteTextField.text=String(format: "%02d",comp.minute)
        secondTextField.text=String(format: "%02d", comp.second)
        errorText.text=""
        
    }
    
    @IBAction func nowButton(sender: AnyObject) {
        //gettimeofday(&time, nil)
        populateNow()
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var nowButton: UIButton!
    
    @IBAction func autoManualSelect(sender: AnyObject) {
        var enabled:Bool
        
        if autoManualValue.selectedSegmentIndex == 0 {
            // manual update
            timer.invalidate()
            nowButton.enabled=true
            recalcButton.enabled=true
            enabled=true
        }
        else {
            // auto update
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updTime"), userInfo: nil, repeats: true)
            nowButton.enabled=false
            recalcButton.enabled=false
            enabled=false
        }
        populateNow()
        yearTextField.enabled=enabled
        monthTextField.enabled=enabled
        dayTextField.enabled=enabled
        hourTextField.enabled=enabled
        minuteTextField.enabled=enabled
        secondTextField.enabled=enabled
        tsTextField.enabled=enabled
    }
    
    func updTime()  {
        
        //gettimeofday(&time, nil)
        
        populateNow()
        
    }
    
    @IBAction func hexDecSelect(sender: AnyObject) {
        var currFormatIsHex:Bool=dohex
        if hexDecValue.selectedSegmentIndex == 0 {
            dohex=false
            tsTextField.keyboardType=UIKeyboardType.NumberPad
        }
        else {
            dohex=true
            tsTextField.keyboardType=UIKeyboardType.Default
        }
        
        if (tsTextField.text.isEmpty) {
            if (tsEdited) {
                populateNow()
            }
            else {
                populateFromDate()
            }
        }
        else {
            populateFromTS(currFormatIsHex)
        }
        
        self.view.endEditing(true)
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

