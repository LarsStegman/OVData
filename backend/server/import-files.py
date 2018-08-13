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
        output_field_names=['[DataOwnerCode]','[PointCode]','[ValidFrom]','[Description]','[LocationX_EW]','[LocationY_NS]'],
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
    )

]


for data in data_types_to_import:
    temp_file = merge_files_into_temp(data)
    call("psql -U larsstegman -d ovdata_db -v data=\"'%s'\" -f database-scripts/%s" % (temp_file, data.db_script), shell=True)
    remove('..' + temp_file)
