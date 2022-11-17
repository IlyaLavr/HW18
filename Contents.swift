
import Foundation

var chipStructs = [Chip]()
let semaphore = DispatchSemaphore(value: 1)

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let chipType: ChipType
    
    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        return Chip(chipType: chipType)
    }
    
    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

var makeTread = Thread {
    for _ in 0...9 {
        chipStructs.append(Chip.make())
        print("Экземпляр создан")
        sleep(2)
    }
}

var workTread = Thread {
    for _ in 0...9 {
        while chipStructs.isEmpty {
            
        }
        semaphore.wait()
        chipStructs.removeFirst().sodering()
        print("Припаяно")
        semaphore.signal()
    }
}

makeTread.start()
workTread.start()
