//
//  ARViewController.swift
//  AR Navigation
//
//  Created by Angela Cheng on 12/2/17.
//  Copyright © 2017 Angela Cheng. All rights reserved.
//

import UIKit
import ARKit
import Alamofire
import SwiftyJSON
import CoreLocation

class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, SCNPhysicsContactDelegate {
    var req = ""
    var steps = [(Double, Double, String)]()
    let locationManager = CLLocationManager()
    var htmlInstructions = [String]()
    var index = 1
    var len = 0
    var testIndex = 0
    let testRoute = ["straight", "straight", "straight", "straight", "turn left", "turn left", "turn left", "straight", "straight", "straight", "straight", "turn right", "turn right", "turn right", "straight", "straight", "straight", "turn left", "turn left", "turn left", "straight", "straight", "destination coming up!", "Maison Mathis Yale on left"]
    var timer = Timer()
    
    
    // ARKit stuff
    @IBOutlet weak var sceneView: ARSCNView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
//    // Plane detection
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        let planeAnchor:ARPlaneAnchor = anchor as! ARPlaneAnchor
//        let planeNode = createPlaneNode(anchor: planeAnchor)
//
//        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
//        node.addChildNode(planeNode)
//    }
//
//    // When updated
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        let planeAnchor:ARPlaneAnchor = anchor as! ARPlaneAnchor
//        node.enumerateChildNodes {
//            (childNode, _) in
//            childNode.removeFromParentNode()
//        }
//        let planeNode = createPlaneNode(anchor: planeAnchor)
//
//        node.addChildNode(planeNode)
//    }
//
//    // When a detected plane is removed, remove the planeNode
//    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        let anchor:ARPlaneAnchor = anchor as! ARPlaneAnchor
//        // Remove existing plane nodes
//        node.enumerateChildNodes {
//            (childNode, _) in
//            childNode.removeFromParentNode()
//        }
//    }

    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)

        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        planeNode.opacity = 0.5
//        let body = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: plane, options: nil))
//        body.mass = 1.5
//        body.restitution = 0.0
//        body.friction = 1.0
//        planeNode.physicsBody = body

        return planeNode
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = true
//        self.makeRoute()
         // Do any additional setup after loading the view.
        sendRequest(requestString: req, completion: {
            self.len = self.steps.count
            print(self.steps)
            print(self.htmlInstructions)
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.distanceFilter = 0.5
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.locationManager.startUpdatingLocation()
            }

        })
        
    }
    
    func makeRoute() {
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: {timer in
            if self.testIndex < self.testRoute.count {
                let maneuver = self.self.testRoute[self.testIndex]
                print(maneuver)
                let pointOfView = self.sceneView.pointOfView!
                let text = SCNText(string: maneuver, extrusionDepth: 4)
                let textNode = SCNNode(geometry: text)
                textNode.geometry = text
                textNode.simdPosition =  pointOfView.simdPosition + pointOfView.simdWorldFront * 0.8
                textNode.scale = SCNVector3(0.01, 0.01, 0.01)
                
                self.sceneView.scene.rootNode.enumerateChildNodes {
                    (childNode, _) in
                    childNode.removeFromParentNode()
                }
                self.sceneView.scene.rootNode.addChildNode(textNode)
                self.testIndex += 1
            } else {
                timer.invalidate()
            }
        })
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let (x1, x2, maneuver) = steps[index]
        let endLoc = CLLocation(latitude: x1, longitude: x2)
        let currLoc:CLLocation = locationManager.location!
        print(currLoc)
        let distanceInMeters = endLoc.distance(from: currLoc)
        
        if distanceInMeters < 2.0 && index < len {
            displayTextManeuver(maneuver: maneuver)
            index += 1
        } else if index < len {
            displayTextManeuver(maneuver: "straight")
        }
        

    }
    
    // Display text
    func displayTextManeuver(maneuver: String) {
        let pointOfView = sceneView.pointOfView!
        let text = SCNText(string: maneuver, extrusionDepth: 4)
        let textNode = SCNNode(geometry: text)
        textNode.geometry = text
        textNode.simdPosition =  pointOfView.simdPosition + pointOfView.simdWorldFront * 0.8
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
//        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: text, options: nil))
//        physicsBody.mass = 0.1
//        physicsBody.restitution = 0.25
//        physicsBody.friction = 0.75
//        physicsBody.categoryBitMask = CollisionTypes.shape.rawValue
//        textNode.physicsBody = physicsBody
//        textNode.physicsBody?.isAffectedByGravity = true
        
        sceneView.scene.rootNode.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    //
    //        let key = planeAnchor.identifier.uuidString
    //        let planeNode = createPlaneNode(anchor: planeAnchor)//NodeGenerator.generatePlaneFrom(planeAnchor: planeAnchor, physics: true, hidden: !self.showPlanes)
    //        node.addChildNode(planeNode)
    //        self.planes[key] = planeNode
    //    }
    //
    //
    //
    //    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    //        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    //
    //        let key = planeAnchor.identifier.uuidString
    //        if let existingPlane = self.planes[key] {
    //            existingPlane.geometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.005, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
    //            existingPlane.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
    ////            NodeGenerator.update(planeNode: existingPlane, from: planeAnchor, hidden: !self.showPlanes)
    //        }
    //    }
    //
    //    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    //        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    //
    //        let key = planeAnchor.identifier.uuidString
    //        if let existingPlane = self.planes[key] {
    //            existingPlane.removeFromParentNode()
    //            self.planes.removeValue(forKey: key)
    //        }
    //    }
    //
    //
    //    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    //        let mask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
    //
    //        if CollisionTypes(rawValue: mask) == [CollisionTypes.bottom, CollisionTypes.shape] {
    //            if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.bottom.rawValue {
    //                contact.nodeB.removeFromParentNode()
    //            } else {
    //                contact.nodeA.removeFromParentNode()
    //            }
    //        }
    //    }

//    private func configureWorldBottom() {
//        let bottomPlane = SCNBox(width: 1000, height: 0.005, length: 1000, chamferRadius: 0)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
//        bottomPlane.materials = [material]
//
//        let bottomNode = SCNNode(geometry: bottomPlane)
//        bottomNode.position = SCNVector3(x: 0, y: -10, z: 0)
//
//        let physicsBody = SCNPhysicsBody.static()
//        physicsBody.categoryBitMask = CollisionTypes.bottom.rawValue
//        physicsBody.contactTestBitMask = CollisionTypes.shape.rawValue
//        bottomNode.physicsBody = physicsBody
//
//        self.sceneView.scene.rootNode.addChildNode(bottomNode)
//        self.sceneView.scene.physicsWorld.contactDelegate = self
//    }
    
    
    // Send the route request to Google API
    func sendRequest(requestString: String, completion : @escaping ()->()) {
        Alamofire.request(requestString)
            .responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)["routes"][0]["legs"][0]["steps"]
                    let arr = json.array!
                    for i in 0..<arr.count {
                        let obj = arr[i]
                        var maneuver = ""
                        if i == 0 {
                            maneuver = "straight"
                        } else {
                            maneuver = obj["maneuver"].stringValue
                        }
                        let lat = obj["end_location"]["lat"].doubleValue
                        let long = obj["end_location"]["lng"].doubleValue
                        print("\(lat) \(long)")
                        self.steps.append((lat, long, maneuver))
                        self.htmlInstructions.append(obj["html_instructions"].stringValue)
                    }
                }
            completion()
        }
    }
}
