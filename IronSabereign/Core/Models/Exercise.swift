import SwiftData
import Foundation

@Model
final class Exercise {
    @Attribute(.unique) var id: String
    var name: String
    var nameEn: String
    var muscleGroupPrimary: MuscleGroup
    var muscleGroupSecondaryRaw: String?
    var equipmentType: EquipmentType
    var movementPattern: MovementPattern
    var defaultWeightMale: Float
    var defaultWeightFemale: Float
    var optimalRepRangeLow: Int
    var optimalRepRangeHigh: Int
    var optimalSets: Int
    var restSeconds: Int
    var rpeTarget: Float
    var weightRatioToBench: Float
    var notes: String?

    var muscleGroupSecondary: MuscleGroup? {
        get { muscleGroupSecondaryRaw.flatMap { MuscleGroup(rawValue: $0) } }
        set { muscleGroupSecondaryRaw = newValue?.rawValue }
    }

    init(id: String, name: String, nameEn: String, muscleGroupPrimary: MuscleGroup,
         muscleGroupSecondary: MuscleGroup? = nil, equipmentType: EquipmentType,
         movementPattern: MovementPattern, defaultWeightMale: Float, defaultWeightFemale: Float,
         optimalRepRangeLow: Int, optimalRepRangeHigh: Int, optimalSets: Int,
         restSeconds: Int, rpeTarget: Float, weightRatioToBench: Float, notes: String? = nil) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.muscleGroupPrimary = muscleGroupPrimary
        self.muscleGroupSecondaryRaw = muscleGroupSecondary?.rawValue
        self.equipmentType = equipmentType
        self.movementPattern = movementPattern
        self.defaultWeightMale = defaultWeightMale
        self.defaultWeightFemale = defaultWeightFemale
        self.optimalRepRangeLow = optimalRepRangeLow
        self.optimalRepRangeHigh = optimalRepRangeHigh
        self.optimalSets = optimalSets
        self.restSeconds = restSeconds
        self.rpeTarget = rpeTarget
        self.weightRatioToBench = weightRatioToBench
        self.notes = notes
    }
}
