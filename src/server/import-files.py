import csv
import glob
from subprocess import call
from os import remove


def merge_files_into_temp(data):
    file_name = '/ovdata-source/import/temp-%s.TMI' % data.type
    with open('..' + file_name, 'w+') as file:
        writer = csv.DictWriter(file, fieldnames=data.output_field_names,
                                delimiter='|')
        # reorder the header first
        writer.writeheader()
        for f in data.input_files():
            print(f)
            with open(f, 'r') as input_file:
                reader = csv.DictReader(input_file, delimiter='|',
                                        fieldnames=data.input_field_names)
                iter = reader.__iter__()
                iter.__next__()  # Ignore header
                for row in iter:
                    # writes the reordered rows to the new file
                    writer.writerow({
                        f: v for f, v in row.items() if f in data.output_field_names
                    })

        file.close()

    return file_name


class TransitDataTypeInformation:

    def __init__(self, type, file_name_pattern, input_field_names,
                 output_field_names, db_script):
        self.type = type
        self.file = file_name_pattern
        self.input_field_names = input_field_names
        self.output_field_names = output_field_names
        self.db_script = db_script

    def input_files(self):
        return glob.iglob("../ovdata-source/*/%s" % self.file)


data_types_to_import = [
    TransitDataTypeInformation(
        type='point',
        file_name_pattern='POINT.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[PointCode]','[ValidFrom]','[PointType]','[CoordinateSystemType]','[LocationX_EW]','[LocationY_NS]','[LocationZ]','[Description]'],
        output_field_names=['[DataOwnerCode]','[PointCode]','[ValidFrom]','[PointType]','[Description]','[LocationX_EW]','[LocationY_NS]'],
        db_script="import-points.sql"
    ),
    TransitDataTypeInformation(
        type='stop_area',
        file_name_pattern= 'USRSTAR.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopAreaCode]','[Name]','[Town]','[RoadSideEqDataOwnerCode]','[RoadSideEqUnitNumber]','[Description]'],
        output_field_names=['[DataOwnerCode]','[UserStopAreaCode]','[Name]','[Town]','[Description]'],
        db_script="import-stop-area.sql"
    ),
    TransitDataTypeInformation(
        type='stop',
        file_name_pattern='USRSTOP.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopCode]','[TimingPointCode]','[GetIn]','[GetOut]','[Deprecated]','[Name]','[Town]','[UserStopAreaCode]','[StopSideCode]','[RoadSideEqDataOwnerCode]','[RoadSideEqUnitNumber]','[MinimalStopTime]','[StopSideLength]','[Description]','[UserStopType]'],
        output_field_names=['[DataOwnerCode]','[UserStopCode]','[TimingPointCode]','[GetIn]','[GetOut]', '[Name]','[Town]','[UserStopAreaCode]','[StopSideCode]','[Description]','[UserStopType]'],
        db_script="import-stops.sql"
    ),
    TransitDataTypeInformation(
        type='tili',
        file_name_pattern='TILI.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[MinimalDriveTime]','[Description]'],
        output_field_names=['[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[MinimalDriveTime]','[Description]'],
        db_script="import-timing-link.sql"
    ),
    TransitDataTypeInformation(
        type='link',
        file_name_pattern='LINK.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[ValidFrom]','[Distance]','[Description]','[TransportType]'],
        output_field_names=['[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[ValidFrom]','[Distance]','[Description]','[TransportType]'],
        db_script="import-link.sql"
    ),
    TransitDataTypeInformation(
        type='pool',
        file_name_pattern='POOL.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[LinkValidFrom]','[PointDataOwnerCode]','[PointCode]','[DistanceSinceStartOfLink]','[SegmentSpeed]','[LocalPointSpeed]','[Description]','[TransportType]'],
        output_field_names=['[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[LinkValidFrom]','[PointDataOwnerCode]','[PointCode]','[DistanceSinceStartOfLink]','[Description]','[TransportType]'],
        db_script="import-point-on-link.sql"
    ),
    TransitDataTypeInformation(
        type='dest',
        file_name_pattern="DEST.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[DestCode]','[DestNameFull]','[DestNameMain]','[DestNameDetail]','[RelevantDestNameDetail]','[DestNameMain21]','[DestNameDetail21]','[DestNameMain19]','[DestNameDetail19]','[DestNameMain16]','[DestNameDetail16]','[DestIcon]','[Destcolor]'],
        output_field_names=['[DataOwnerCode]','[DestCode]','[DestNameFull]','[DestNameMain]','[DestNameDetail]','[RelevantDestNameDetail]','[DestNameMain21]','[DestNameDetail21]','[DestNameMain19]','[DestNameDetail19]','[DestNameMain16]','[DestNameDetail16]'],
        db_script="import-destination.sql"
    ),
    TransitDataTypeInformation(
        type='line',
        file_name_pattern="LINE.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[LinePlanningNumber]','[LinePublicNumber]','[LineName]','[LineVeTagNumber]','[Description]','[TransportType]','[LineIcon]','[LineColor]'],
        output_field_names=['[DataOwnerCode]','[LinePlanningNumber]','[LinePublicNumber]','[LineName]','[Description]','[TransportType]'],
        db_script="import-line.sql"
    ),
    TransitDataTypeInformation(
        type='jopa',
        file_name_pattern="JOPA.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit/Explicit]','[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[JourneyPatternType]','[Direction]','[Description]'],
        output_field_names=['[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[Direction]','[Description]'],
        db_script="import-journey-pattern.sql"
    ),
    TransitDataTypeInformation(
        type='jopatili',
        file_name_pattern="JOPATILI.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[TimingLinkOrder]','[UserStopCodeBegin]','[UserStopCodeEnd]','[ConFinRelCode]','[DestCode]','[DeprecatedFormulaCode]','[IsTimingStop]','[DisplayPublicLine]','[ProductFormulaType]'],
        output_field_names=['[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[TimingLinkOrder]','[UserStopCodeBegin]','[UserStopCodeEnd]','[DestCode]','[IsTimingStop]','[DisplayPublicLine]'],
        db_script="import-journey-pattern-timing-link.sql"
    )
]

for data in data_types_to_import:
    temp_file = merge_files_into_temp(data)
    call("psql -U larsstegman -d ovdata_db -v data=\"'%s'\" -f database-scripts/import/%s" % (temp_file, data.db_script), shell=True)
    remove('..' + temp_file)

call("psql -U larsstegman -d ovdata_db -f database-scripts/import/refresh-views.sql", shell=True)
