import Foundation

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

class Storage {
    var chipStructs = [Chip]()
    let semaphore = DispatchSemaphore(value: 1)
    
    func appendChip(chip: Chip) {
        semaphore.wait()
        chipStructs.append(chip)
        print("\(Date()), Чип \(chip.chipType.rawValue) добавлен в хранилище. В хранилище чипы \(chipStructs.map { $0.chipType.rawValue })")
        semaphore.signal()
    }
    
    func removeChip() -> Chip? {
        semaphore.wait()
        var chip: Chip?
        if let deletedChip = chipStructs.popLast() {
            chip = deletedChip
            print("\(Date()), Чип \(deletedChip.chipType.rawValue) взят из хранилища для пайки. В хранилище чипы \(chipStructs.map { $0.chipType.rawValue })")
            semaphore.signal()
        }
        semaphore.signal()
        return chip
    }
}

class MakeTread: Thread {
    let storage: Storage
    var timeInterval: Double? = nil
    
    init(storage: Storage, timeInterval: Double) {
        self.storage = storage
        self.timeInterval = timeInterval
    }
    override func main() {
        for _ in 0...9 {
            let newChip = Chip.make()
            MakeTread.sleep(forTimeInterval: TimeInterval(timeInterval ?? Double(newChip.chipType.rawValue)))
            print("\(Date()), Cоздан чип \(newChip.chipType.rawValue). В хранилище чипы \(storage.chipStructs.map { $0.chipType.rawValue })")
            storage.appendChip(chip: newChip)
        }
        cancel()
        print("Создание чипов завершено. MakeTread завершен")
    }
}

class WorkTread: Thread {
    var storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    override func main() {
        while !make.isCancelled || storage.chipStructs.count > 0 {
            if !storage.chipStructs.isEmpty {
                if let chip = storage.removeChip() {
                    chip.sodering()
                    print("\(Date()), Чип \(chip.chipType.rawValue) припаян. В хранилище чипы \(storage.chipStructs.map { $0.chipType.rawValue })\n")
                }
            }
        }
        cancel()
        print("Все чипы припаяны. WorkTread завершен")
    }
}

let storage = Storage()

let make = MakeTread(storage: storage, timeInterval: 2)
let work = WorkTread(storage: storage)


make.start()
work.start()


