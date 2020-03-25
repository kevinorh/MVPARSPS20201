//
//  Skeleton.swift
//  BodyDetection
//
//  Created by Kevin Ore on 3/7/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
class Skeleton{
    var leftHandPosition : SIMD3<Float> = [0,0,0]
    var rigthHandPosition: SIMD3<Float> = [0,0,0]
    
    init (leftHand:SIMD3<Float>,rightHand:SIMD3<Float>){
        self.leftHandPosition = leftHand
        self.rigthHandPosition = rightHand
    }
    func getLeftHandMovementSpeed (lastJointPosition: SIMD3<Float>) -> Float {
        return pow(leftHandPosition.x - lastJointPosition.x,2)+pow(leftHandPosition.y - lastJointPosition.y,2)+pow(leftHandPosition.z - lastJointPosition.y,2);
    }
    func getRigthHandMovementSpeed (lastJointPosition: SIMD3<Float>) -> Float {
        
        return pow(rigthHandPosition.x - lastJointPosition.x,2)+pow(rigthHandPosition.y - lastJointPosition.y,2)+pow(rigthHandPosition.z - lastJointPosition.y,2);
    }
    
}
