//
//  ClippingMethod.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/19.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

public enum ClippingMethod {
    case object(objectType: ObjectType)
    case selectTouch
    case selectValue(value: Int32)
}

public enum ObjectType: Int32 {
    case human = 15
    case fish = 3
}
