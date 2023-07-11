//
//  GameViewController.swift
//  RenderLoopPrac03
//
//  Created by SDBX on 11/7/2023.
//

let DESIRED_FRAME_RATE = 2 * 60;

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {
    
    /*
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        <#code#>
    }
    
    func draw(in view: MTKView) {
        <#code#>
    }
    */

    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        let defaultDevices = MTLCopyAllDevices();
        
        guard (defaultDevices.count >= 1) else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevices[1];
        print(mtkView.device!.name)

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        (mtkView.layer as! CAMetalLayer).displaySyncEnabled = false;
        mtkView.preferredFramesPerSecond = DESIRED_FRAME_RATE;
        
        mtkView.isPaused = false;
        mtkView.enableSetNeedsDisplay = false;
        
        mtkView.layer?.drawsAsynchronously = true;
        
        (mtkView.layer as! CAMetalLayer).allowsNextDrawableTimeout = true;
        
        // TEST: Bring back the delegate...
        mtkView.delegate = renderer;
        
        let renderThread = Thread {
             //in //[self.mtkView]
                while(true) {
                    autoreleasepool(invoking: {
                        // mtkView.delegate?.draw(in: mtkView);
                        //DispatchQueue.concurrentPerform(iterations: 4, execute: { _ in
                        //    let renderer = newRenderer;
                        //    renderer.draw(in: mtkView);
                        mtkView.draw();
                        //})
                        // self.renderer = newRenderer;
                        // self.renderer.draw(in: mtkView);
                        // mtkView.draw();
                        // self.renderer = nil;
                    })
                }
            //})
        }
        renderThread.name = "Render Thread";
        renderThread.start()
    }
}
