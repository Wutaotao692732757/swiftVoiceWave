//
//  ViewController.swift
//  SwiftVoiceWave
//
//  Created by wutaotao on 2017/1/9.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

import UIKit
import AVFoundation

 let Screew = UIScreen.main.bounds.size.width

class ViewController: UIViewController {

    let myshapLayer = CAShapeLayer();

    var recoder : AVAudioRecorder?;
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        myshapLayer.strokeColor=UIColor.gray.cgColor;
        myshapLayer.fillColor=UIColor.clear.cgColor;
        myshapLayer.lineWidth=2.0;
        myshapLayer.lineCap=kCALineCapRound;
        myshapLayer.lineJoin=kCALineJoinMiter;
        
        self.view.layer.addSublayer(myshapLayer);
        
        let disPlayLinker = CADisplayLink.init(target: self, selector:#selector(ViewController.updateShap))
        disPlayLinker.add(to: RunLoop.current, forMode: RunLoopMode.commonModes);
      
    
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            // 发生了错误
            print(error.localizedDescription)
        }
        

      let url = URL.init(fileURLWithPath: "dev/null")
        
      let dic2 = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 2, //录音的声道数，立体声为双声道
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVSampleRateKey : 44100.0 //录音器每秒采集的录音样本数
        ] as [String : Any];
        
        do {
            try recoder =  AVAudioRecorder.init(url: url, settings: dic2)
         
        } catch let error as NSError {
            // 发生了错误
            print(error.localizedDescription)
        }
        
        
            recoder?.prepareToRecord();
            recoder?.isMeteringEnabled=true;
            recoder?.record();
        
    }
    
    var count = 0;
    var decibels:float_t=0.0;
    func updateShap(){

        recoder?.updateMeters();
        var lever:CGFloat=0.0;
        let minDecibels:CGFloat = -80.0;
        
        decibels=(recoder?.averagePower(forChannel: 0))!;
        
          let deci2=recoder?.averagePower(forChannel: 0);
        print("ssss--%f",deci2);
        if (float_t(decibels
            
            )<float_t(minDecibels)) {
            lever=0.0;
        }else if (float_t(decibels)>0.0){
            lever=1.0;
        }else{
            
           let  minAmp  = powf(10.0, float_t(0.05) * float_t(minDecibels));
           let  amp     = powf(10.0, float_t(0.05) * float_t(decibels));
           let   root            = 2.0;
           let   inverseAmpRange = 1.0 / (1.0 - minAmp);
           let   adjAmp          = (amp - minAmp) * inverseAmpRange;
            
            lever = CGFloat(powf(adjAmp, float_t(1.0) / float_t(root)));
            
        }
        
        
        
        count=count+1
        UIGraphicsBeginImageContext(CGSize(width:375,height:669));
        let path = UIBezierPath.init()
        //振幅
        let maxHeight:CGFloat = 100.0
        //便宜度数
        let degree = float_t(0.2)*float_t(count)
        
        let max = NSInteger(Screew);
        for i in 0...max{
            
            let x:CGFloat = 0.0+CGFloat(i)
            //中间高两边低
            let scaleHeight=CGFloat(sinf((float_t(x)/float_t(Screew))*float_t(M_PI)))
            let y:CGFloat = CGFloat(sinf((float_t(x)/float_t(Screew))*float_t(M_PI*2)-degree)*float_t(maxHeight))*lever*scaleHeight
            
            
            if i==0 {
                path.move(to: CGPoint(x:x,y:400+y))
                
            }else{
                path.addLine(to: CGPoint(x:x,y:400+y))
            }
            
            
            
            
        }
        
        myshapLayer.path=path.cgPath
        UIGraphicsEndImageContext()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

