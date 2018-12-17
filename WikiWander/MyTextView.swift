//
//  MyTextView.swift
//  WikiWander
//
//  Created by Bethany Anne Drake on 17/12/18.
//  Copyright © 2018 WordWatch. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class MyTextView : UITextView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //var pos = .closestPosition(to: touches.first?.location(in: self))
        //print(pos)
        print("hello! touch began!")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("hello! touch ended!")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("hello! touch cancelled!")
    }
    
    @IBOutlet weak var view: UITextView!
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        //setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //setup()
    }
    
//    func setup() {
//        view = loadViewFromNib() as? UITextView
//        view.frame = bounds
//
//        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,
//                                 UIView.AutoresizingMask.flexibleHeight]
//
//        addSubview(view)
//
//        // Add our border here and every custom setup
//        view.layer.borderWidth = 2
//        view.layer.borderColor = UIColor.white.cgColor
//        view.font = UIFont.systemFont(ofSize: 40)
//    }
    
//    func loadViewFromNib() -> UIView! {
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
//        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIButton
//
//        return view
//    }
}
