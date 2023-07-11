//
//  GameViewController.swift
//  RenderLoopPrac02
//
//  Created by SDBX on 8/7/2023.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

    var renderer: Renderer!
    // var mtkView: MTKView?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer
        
        // SDBX:
        (mtkView.layer as! CAMetalLayer).displaySyncEnabled = false;
        mtkView.preferredFramesPerSecond = 240;
        
        // Maybe modify the timeout?
        (mtkView.layer as! CAMetalLayer).allowsNextDrawableTimeout = true;

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        // TODO: mtkView.delegate = renderer
        
        mtkView.layer?.allowsEdgeAntialiasing = true;
        mtkView.layer?.edgeAntialiasingMask = .layerBottomEdge
        mtkView.layer?.drawsAsynchronously = true;
        
        print("mtkView.preferredFramesPerSecond:", mtkView.preferredFramesPerSecond);
        usleep(3_000_000);
        
        func betterway() {
            // Set up and run the Metal render loop.
            let renderThread = Thread {
                // TODO: let engine = myEngineCreate(layerRenderer)
                // myEngineRenderLoop(engine)
                
                let is_rendering: Bool = true;
                
                while (is_rendering) {
                    autoreleasepool {
                        // TODO: *** TEST HERE ***
                        self.renderer?.draw(in: mtkView);
                        // return
                    } // END: autoreleasepool
                }
            }
            renderThread.name = "RenderLoop 01 - Main Render Thread"
            renderThread.start();
        }
        betterway()
    }
}
