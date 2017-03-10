//
//  OpenCCConverter.swift
//  OpenCC
//
//  Created by 邓翔 on 2017/3/9.
//
//

import Foundation
import OpenCCBridge

/// The `ChineseConverter` class is used to represent and apply conversion
/// between Traditional Chinese and Simplified Chinese to Unicode strings.
/// An instance of this class is an immutable representation of a compiled
/// conversion pattern.
/// The `ChineseConverter` supporting character-level conversion, phrase-level
/// conversion, variant conversion and regional idioms among Mainland China,
/// Taiwan and HongKong
public class ChineseConverter {
    
    let converter: ObjcConverter
    
    /// Returns an initialized `ChineseConverter` instance with the specified
    /// conversion option.
    ///
    /// - Parameter option: The convert’s option.
    public init(option: Options) {
        let config = option.config
        converter = ObjcConverter(config: config)
    }
    
    /// Return a converted string using the convert’s current option.
    ///
    /// - Parameter text: The string to convert.
    /// - Returns: A converted string using the convert’s current option.
    public func convert(_ text: String) -> String {
        return converter.convert(text)
    }
    
}

extension ChineseConverter {
    
    /// These constants define the ChineseConverter options.
    /// These constants are used to initialize `ChineseConverter`.
    public struct Options: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Conversion direction.
        /// not compatible with `.simplify`.
        ///
        /// If direction is conflictive, using `.traditionalize`.
        public static let traditionalize = Options(rawValue: 1 << 0)
        
        /// Conversion direction.
        /// not compatible with `.traditionalize`.
        ///
        /// If direction is conflictive, using `.traditionalize`.
        public static let simplify = Options(rawValue: 1 << 1)
        
        /// Use Taiwan standard.
        /// not compatible with `.HKStandard`.
        ///
        /// If standard is absent or conflictive, using OpenCC standard.
        public static let TWStandard = Options(rawValue: 1 << 5)
        
        /// Use HongKong standard.
        /// not compatible with `.TWStandard`.
        ///
        /// If standard is absent or conflictive, using OpenCC standard.
        public static let HKStandard = Options(rawValue: 1 << 6)
        
        /// Taiwanese idiom conversion.
        /// Both available in traditionalization and simplification.
        ///
        /// - Precondition: Only effective with direction and `.TWStandard`.
        public static let TWIdiom = Options(rawValue: 1 << 10)
        
        /// Use text format dictionary.
        /// Text dictionary is smaller than default ocd dictionary, and
        /// therefore consume less memory, But **much slower**.
        ///
        /// 50x slower than default ocd dictionary!!!
        public static let textDict = Options(rawValue: 1 << 15)
        
        func normalizing() -> Options {
            var options = self
            if options.contains([.traditionalize, .simplify]) {
                options.remove(.simplify)
            }
            if options.contains([.HKStandard, .TWStandard]) {
                options.remove([.HKStandard, .TWStandard])
            }
            if options.contains(.TWIdiom),
                !options.contains(.TWStandard) ||
                    (!(options.contains(.simplify)) && !options.contains(.traditionalize)) {
                options.remove(.TWIdiom)
            }
            return options
        }
        
        var config: String {
            let options = normalizing().subtracting(.textDict)
            var name: String
            switch options {
            case [.traditionalize], []:
                name = "s2t"
            case [.simplify]:
                name = "t2s"
            case [.traditionalize, .TWStandard]:
                name = "s2tw"
            case [.simplify, .TWStandard]:
                name = "tw2s"
            case [.traditionalize, .HKStandard]:
                name = "s2hk"
            case [.simplify, .HKStandard]:
                name = "hk2s"
            case [.traditionalize, .TWStandard, .TWIdiom]:
                name = "s2twp"
            case [.simplify, .TWStandard, .TWIdiom]:
                name = "tw2sp"
            case [.TWStandard]:
                name = "t2tw"
            case [.HKStandard]:
                name = "t2hk"
            default:
                name = "s2t"
            }
            if contains(.textDict) {
                name += "_txt"
            }
            return Bundle(for: ChineseConverter.self).path(forResource: name, ofType: "json")!
        }
        
    }
    
}
