//
//  ViewController.swift
//  SolarSystem
//
//  Created by Shalev Lazarof on 15/07/2019.
//  Copyright © 2019 Shalev Lazarof. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var sunNode = SCNNode()
    var earthNode = SCNNode()
    var moonNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // MARK: Plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    @IBAction func moveButtonPressed(_ sender: Any) {
        moveStars()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        moonNode.removeAction(forKey: "moonAction")
        earthNode.removeAction(forKey: "earthAction")
    }
    
    func moveStars(){
        let moonAction = SCNAction.rotateBy(x: 0, y: CGFloat(3 * Double.pi), z: 0, duration: 10)
        let moonRepAction = SCNAction.repeatForever(moonAction)
        moonNode.runAction(moonRepAction, forKey: "moonAction")
        
        let earthAction = SCNAction.rotateBy(x: 0, y: CGFloat(Double.pi), z: 0, duration: 10)
        let earthRepAction = SCNAction.repeatForever(earthAction)
        earthNode.runAction(earthRepAction, forKey: "earthAction")
    }

}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            planeNode.geometry = plane
            
            let planeNodeMaterial = SCNMaterial()
            planeNodeMaterial.diffuse.contents = UIColor.transparentLightBlue
            plane.materials = [planeNodeMaterial]
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
    
    // MARK: User touched the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                
                // MARK: Sun
                let sun = SCNSphere(radius: 0.100)
                let sunMaterial = SCNMaterial()
                sunMaterial.diffuse.contents = UIImage(named: "art.scnassets/sun.jpg")
                sun.materials = [sunMaterial]
                
                sunNode = SCNNode()
                sunNode.geometry = sun
                
                sunNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x + 0.3,
                                              y: (hitResult.worldTransform.columns.3.y + (sunNode.boundingSphere.radius * 2)),
                                              z: hitResult.worldTransform.columns.3.z)
                
                // MARK: Earth
                let earth = SCNSphere(radius: 0.040)
                
                let earthMaterial = SCNMaterial()
                earthMaterial.diffuse.contents = UIImage(named: "art.scnassets/earth.jpg")
                earth.materials = [earthMaterial]
                
                earthNode = SCNNode()
                earthNode.geometry = earth
                earthNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                                y: hitResult.worldTransform.columns.3.y + earthNode.boundingSphere.radius,
                                                z: hitResult.worldTransform.columns.3.z)
                
                // MARK: Moon
                let moon = SCNSphere(radius: 0.010)
                
                let moonMaterial = SCNMaterial()
                moonMaterial.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
                moon.materials = [moonMaterial]
                
                moonNode = SCNNode()
                moonNode.geometry = moon
                
                moonNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x + -0.1,
                                               y: (hitResult.worldTransform.columns.3.y + (moonNode.boundingSphere.radius)),
                                               z: hitResult.worldTransform.columns.3.z)
                
                // MARK: Add all stars
                sceneView.scene.rootNode.addChildNode(sunNode)
                sceneView.scene.rootNode.addChildNode(earthNode)
                sceneView.scene.rootNode.addChildNode(moonNode)
                
            }
        }
    }
}
