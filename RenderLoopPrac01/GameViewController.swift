//  GameViewController.swift
//  RenderLoopPrac01
//  Created by SDBX on 6/7/2023.

import Cocoa
import MetalKit

let BASE_FPS_COEFF     = 36;
let DESIRED_FRAME_RATE = BASE_FPS_COEFF * 30; // 12 x 30 = 360.

// Our macOS specific view controller
class GameViewController: NSViewController {

    public static var currentDevice: MTLDevice!
    
    // var cvDisplay      = CVDisplayLink();
    // var displayLink : CVDisplayLink?
    
    // var animationTimer : Timer?
    var renderer: Renderer?
    public static var mtkView: MTKView! // = MTKView()
    
    /* override func viewDidLoad(){
        super.viewDidLoad()
        mtkView = MTKView(frame: self.view.bounds)
        mtkView.device=MTLCreateSystemDefaultDevice()
        mtkView.enableSetNeedsDisplay=true
    } */
    
    func initialize() {
        
        // super.init(nibName: NSNib.Name(), bundle: <#T##Bundle?#>)
        
        // Select the device to render with.  We choose the default device
        let defaultDevices = MTLCopyAllDevices()
        
        /* else {
            print("Metal is not supported on this device")
            return
        } */
        
        var externalGPUs = [MTLDevice]()
        var discreteGPUs = [MTLDevice]()
        var integratedGPUs = [MTLDevice]()

        for device in defaultDevices {
            if device.isRemovable { externalGPUs.append(device) } else
            if device.isLowPower { integratedGPUs.append(device) } else {
                discreteGPUs.append(device)
            }
        }
        
        GameViewController.currentDevice = discreteGPUs.first;
        
        GameViewController.mtkView = MTKView(frame: self.view.frame, device: discreteGPUs.first)
        view = GameViewController.mtkView;
        
        GameViewController.mtkView.device = discreteGPUs.first;
        print(GameViewController.mtkView.device!.name)
        // mtkView!.device.backgroundthread
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize();
        
        /* guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        } */
        
        // mtkView = (self.view as! MTKView)
        // mtkView = MTKView(frame: self.view.bounds)

        

        let newRenderer = Renderer(metalKitView: GameViewController.mtkView)

        renderer = newRenderer

        renderer!.mtkView(GameViewController.mtkView, drawableSizeWillChange: GameViewController.mtkView.drawableSize)

        // TESTING DELEGATE:
        // mtkView.delegate = renderer
        
        // These two should be SET TRUE:
        GameViewController.mtkView.isPaused = true;
        GameViewController.mtkView.enableSetNeedsDisplay = true;
        
        GameViewController.mtkView.preferredFramesPerSecond = DESIRED_FRAME_RATE;
        
        (GameViewController.mtkView.layer as! CAMetalLayer).framebufferOnly = true; // TESTING...
        (GameViewController.mtkView.layer as! CAMetalLayer).presentsWithTransaction = false; // ...
        (GameViewController.mtkView.layer as! CAMetalLayer).allowsNextDrawableTimeout = false;
        // (mtkView!.layer as! CAMetalLayer). = true;
        
        // SDBX: *** NAILED IT ***
        (GameViewController.mtkView.layer as! CAMetalLayer).displaySyncEnabled = true;
        
        // self.view = mtkView
        // mtkView = self.view
    }
    
    override func viewDidAppear() {
        
        // This probably should NOT be inside of: viewDidLoad
        /* Task {
            while(true) {
                // self.view.draw(<#T##dirtyRect: NSRect##NSRect#>)
                // MTKView.drawRect();
                // mtkView.drawRect()
                renderer!.draw(in: mtkView!)
                // self.view.draw(view.visibleRect)
                // mtkView.releaseDrawables()
                usleep(1_000_000 / 5000)
            }
        } */
        
        /* Task {
            usleep(3_000_000);
            while(true) {
                DispatchQueue.main.async {
                    self.renderer!.draw(in: self.mtkView!);
                    // self.renderer!.draw(in: self.view);
                    // self.view.setNeedsDisplay(self.view.visibleRect);
                    self.view.draw(self.view.visibleRect)
                    usleep(1_000_000 / DESIRED_FRAME_RATE)
                }
            }
        } */
        
        // BAD: mtkView.preferredFramesPerSecond = DESIRED_FRAME_RATE;
        
        let caani = CAAnimation() //.preferredFrameRateRange
        print(caani.preferredFrameRateRange)
        
        func oldway() {
            // Update the view at roughly 60 Hz
            // DispatchQueue.main.sync {
            
            let THREAD_COUNT = 1;
            
                for _ in 1...THREAD_COUNT {
                    
                    // usleep(1_000_000 / 60 / 12)
                    
                    // DispatchQueue.concurrentPerform(iterations: 1, execute: { _ in
                    // DispatchQueue.main. {
                        let animationTimer = Timer.scheduledTimer(withTimeInterval: (1.00000 / (Double(DESIRED_FRAME_RATE) / Double(THREAD_COUNT))), repeats: true, block: { (timer) in
                                //Edit: example update of the data before redrawing
                            
                            // self.renderer
                            
                            // TEST:
                            
                            // self.mtkView?.setNeedsDisplay(self.mtkView!.frame)
                            
                            // TODO: *** TEST HERE ***
                            self.renderer?.draw(in: GameViewController.mtkView);
                            GameViewController.mtkView?.setNeedsDisplay(self.view.frame);
                            
                            // TODO: *** .displayIfNeeded() slows rendering ***
                            self.view.needsDisplay = true;
                            // self.view.displayIfNeeded()
                            
                                // BAD:
                            //DispatchQueue.main.async {
                            // self.view.setNeedsDisplay(self.view.frame);
                            //}
                            // Too many calls:
                            // self.view.setNeedsDisplay(self.view.frame);
                        })
                    // END: DQ: "}"; // END: GCD ")";
                }
                // TEST:
            func priAniTimer() {
                let primaryAnimationTimer = Timer.scheduledTimer(withTimeInterval: (1.00000 / Double(DESIRED_FRAME_RATE)), repeats: true, block: { (timer) in
                    self.view.setNeedsDisplay(self.view.frame);
                    // TEST: self.view.draw(self.view.frame)
                })
            }
            // NOT CALLING PRIANITIMER()!
            // } // .main.async
        }
        // oldway()
        
        func newway() {
            /* CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
             // CVDisplayLinkSetOutputCallback(displayLink, MyDisplayLinkCallback(), self);
             CVDisplayLinkSetOutputHandler(displayLink!, <#T##handler: CVDisplayLinkOutputHandler##CVDisplayLinkOutputHandler##(CVDisplayLink, UnsafePointer<CVTimeStamp>, UnsafePointer<CVTimeStamp>, CVOptionFlags, UnsafeMutablePointer<CVOptionFlags>) -> CVReturn#>)
             CVDisplayLinkStart(displayLink!); */
            
            // CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
            // ???
            // CVDisplayLinkStart(displayLink!);
            // Not used [yet]: displayLink
        }
        // .....
        
        func betterway() {
            // Set up and run the Metal render loop.
            let renderThread = Thread {
                // TODO: let engine = myEngineCreate(layerRenderer)
                // myEngineRenderLoop(engine)
                
                let is_rendering: Bool = true;
                
                while (is_rendering) {
                    autoreleasepool {
                        // TODO: *** TEST HERE ***
                        self.renderer?.draw(in: GameViewController.mtkView);
                    } // END: autoreleasepool
                }
            }
            renderThread.name = "RenderLoop 01 - Main Render Thread"
            renderThread.start()
            
            Timer.scheduledTimer(withTimeInterval: (1.00000 / Double(DESIRED_FRAME_RATE)), repeats: true, block: { (timer) in
                self.view.setNeedsDisplay(self.view.frame);
                // TEST: self.view.draw(self.view.frame)
            })
        }
        betterway()
    }
    /* static func MyDisplayLinkCallback(displayLink: CVDisplayLink , now: CVTimeStamp, outputTime: CVTimeStamp, flagsIn: CVOptionFlags, flagsOut: CVOptionFlags, displayLinkContext: Void) -> CVReturn
    {
        (displayLinkContext as GameViewController).displayLink.setneed
        [(MyMetalView *)displayLinkContext setNeedsDisplay:YES];
        return kCVReturnSuccess;
    } */
}

// TODO: *** myEngineRenderLoop() ***
/* func myEngineRenderLoop(engine: my_engine) {
    
    // TODO: my_engine_setup_render_pipeline(engine);
    
    var is_rendering: Bool = true;
    
    while (is_rendering) {
        autoreleasepool {
            switch (cp_layer_renderer_get_state(engine->layer_renderer)) {
                
            case cp_layer_renderer_state_paused:
                // Wait until the scene appears.
                cp_layer_renderer_wait_until_running(layer);
                break;
                
            case cp_layer_renderer_state_running:
                // Render the next frame.
                my_engine_render_new_frame(engine);
                break;
                
            case cp_layer_renderer_state_invalidated:
                // Exit the render loop.
                is_rendering = false;
                break;
            }
        }
        // TODO: my_engine_invalidate(engine);
    }
} */






