/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine

import SceneKit.ModelIO

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    // The 3D character to display.
    var character: BodyTrackedEntity?
    var characterOffset: SIMD3<Float> = [-1.0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    var lastLeftHandPosition: SIMD3<Float> = [0,0,0]
    var lastRigthHandPosition: SIMD3<Float> = [0,0,0]
    
    @IBOutlet weak var LeftHandLabel: UILabel!
    @IBOutlet weak var RigthHandLabel: UILabel!
    
    @IBOutlet weak var MessagesLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            self.MessagesLabel.text = "La aplicación no es compatible con el dispositivo"
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [0.3, 0.3, 0.3]
                self.character = character
                cancellable?.cancel()
            } else {
                self.MessagesLabel.text = "No fue posible cargar la figura"
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            let rigthhandPosition = simd_make_float3((bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName.rightHand)?.columns.3)!)
            let lefthandPosition = simd_make_float3((bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName.leftHand)?.columns.3)!)
            
            var skeleton = Skeleton(leftHand: lefthandPosition, rightHand: rigthhandPosition)
            var leftHandSpeed = skeleton.getLeftHandMovementSpeed(lastJointPosition: lastLeftHandPosition)
            var rigthHandSpeed = skeleton.getRigthHandMovementSpeed(lastJointPosition: lastRigthHandPosition)
            
            lastLeftHandPosition = skeleton.leftHandPosition
            lastRigthHandPosition = skeleton.rigthHandPosition
            
            LeftHandLabel.text = "Left Hand: \(leftHandSpeed)"
            RigthHandLabel.text = "Rigth Hand: \(rigthHandSpeed)"
            
            
            print("LeftHand: \(leftHandSpeed*100) RigthHand: \(rigthHandSpeed*100)")
            
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            
            characterOffset=skeleton.leftHandPosition
            characterAnchor.position = bodyPosition + characterOffset
            
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
            
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
            }
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            if accessGranted == true{
                    self.MessagesLabel.text = ""
            } else { return }
        })
    }
    
}
