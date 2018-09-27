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


common_data_types = [
    TransitDataTypeInformation(
        type='point',
        file_name_pattern='POINT.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[PointCode]','[ValidFrom]','[PointType]','[CoordinateSystemType]','[LocationX_EW]','[LocationY_NS]','[LocationZ]','[Description]'],
        output_field_names=['[DataOwnerCode]','[PointCode]','[ValidFrom]','[PointType]','[Description]','[LocationX_EW]','[LocationY_NS]'],
        db_script="common/import-points.sql"
    ),
    TransitDataTypeInformation(
        type='stop_area',
        file_name_pattern= 'USRSTAR.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopAreaCode]','[Name]','[Town]','[RoadSideEqDataOwnerCode]','[RoadSideEqUnitNumber]','[Description]'],
        output_field_names=['[DataOwnerCode]','[UserStopAreaCode]','[Name]','[Town]','[Description]'],
        db_script="common/import-stop-area.sql"
    ),
    TransitDataTypeInformation(
        type='stop',
        file_name_pattern='USRSTOP.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopCode]','[TimingPointCode]','[GetIn]','[GetOut]','[Deprecated]','[Name]','[Town]','[UserStopAreaCode]','[StopSideCode]','[RoadSideEqDataOwnerCode]','[RoadSideEqUnitNumber]','[MinimalStopTime]','[StopSideLength]','[Description]','[UserStopType]'],
        output_field_names=['[DataOwnerCode]','[UserStopCode]','[TimingPointCode]','[GetIn]','[GetOut]', '[Name]','[Town]','[UserStopAreaCode]','[StopSideCode]','[Description]','[UserStopType]'],
        db_script="common/import-stops.sql"
    ),
    TransitDataTypeInformation(
        type='tili',
        file_name_pattern='TILI.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[MinimalDriveTime]','[Description]'],
        output_field_names=['[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[MinimalDriveTime]','[Description]'],
        db_script="common/import-timing-link.sql"
    ),
    TransitDataTypeInformation(
        type='link',
        file_name_pattern='LINK.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[ValidFrom]','[Distance]','[Description]','[TransportType]'],
        output_field_names=['[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[ValidFrom]','[Distance]','[Description]','[TransportType]'],
        db_script="common/import-link.sql"
    ),
    TransitDataTypeInformation(
        type='pool',
        file_name_pattern='POOL.TMI',
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[LinkValidFrom]','[PointDataOwnerCode]','[PointCode]','[DistanceSinceStartOfLink]','[SegmentSpeed]','[LocalPointSpeed]','[Description]','[TransportType]'],
        output_field_names=['[DataOwnerCode]','[UserStopCodeBegin]','[UserStopCodeEnd]','[LinkValidFrom]','[PointDataOwnerCode]','[PointCode]','[DistanceSinceStartOfLink]','[Description]','[TransportType]'],
        db_script="common/import-point-on-link.sql"
    ),
    TransitDataTypeInformation(
        type='dest',
        file_name_pattern="DEST.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[DestCode]','[DestNameFull]','[DestNameMain]','[DestNameDetail]','[RelevantDestNameDetail]','[DestNameMain21]','[DestNameDetail21]','[DestNameMain19]','[DestNameDetail19]','[DestNameMain16]','[DestNameDetail16]','[DestIcon]','[Destcolor]'],
        output_field_names=['[DataOwnerCode]','[DestCode]','[DestNameFull]','[DestNameMain]','[DestNameDetail]','[RelevantDestNameDetail]','[DestNameMain21]','[DestNameDetail21]','[DestNameMain19]','[DestNameDetail19]','[DestNameMain16]','[DestNameDetail16]'],
        db_script="common/import-destination.sql"
    ),
    TransitDataTypeInformation(
        type='line',
        file_name_pattern="LINE.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[LinePlanningNumber]','[LinePublicNumber]','[LineName]','[LineVeTagNumber]','[Description]','[TransportType]','[LineIcon]','[LineColor]'],
        output_field_names=['[DataOwnerCode]','[LinePlanningNumber]','[LinePublicNumber]','[LineName]','[Description]','[TransportType]'],
        db_script="common/import-line.sql"
    ),
    TransitDataTypeInformation(
        type='jopa',
        file_name_pattern="JOPA.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit/Explicit]','[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[JourneyPatternType]','[Direction]','[Description]'],
        output_field_names=['[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[Direction]','[Description]'],
        db_script="common/import-journey-pattern.sql"
    ),
    TransitDataTypeInformation(
        type='jopatili',
        file_name_pattern="JOPATILI.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[TimingLinkOrder]','[UserStopCodeBegin]','[UserStopCodeEnd]','[ConFinRelCode]','[DestCode]','[DeprecatedFormulaCode]','[IsTimingStop]','[DisplayPublicLine]','[ProductFormulaType]'],
        output_field_names=['[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[TimingLinkOrder]','[UserStopCodeBegin]','[UserStopCodeEnd]','[DestCode]','[IsTimingStop]','[DisplayPublicLine]'],
        db_script="common/import-journey-pattern-timing-link.sql"
    ),
    TransitDataTypeInformation(
        type='orun',
        file_name_pattern="ORUN.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[OrganizationalUnitCode]','[Name]','[OrganizationalUnitType]','[Description]'],
        output_field_names=['[DataOwnerCode]','[OrganizationalUnitCode]','[Name]','[OrganizationalUnitType]','[Description]'],
        db_script="common/import-organizational-unit.sql"
    ),
    TransitDataTypeInformation(
        type='orun-rel',
        file_name_pattern="ORUNORUN.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[OrganizationalUnitcodeParent]','[OrganizationalUnitcodeChild]','[ValidFrom]'],
        output_field_names=['[DataOwnerCode]','[OrganizationalUnitcodeParent]','[OrganizationalUnitcodeChild]','[ValidFrom]'],
        db_script="common/import-organization-unit-relations.sql"
    )
]

time_demand_group_types = [
# Time Demand Group Schedules
    TransitDataTypeInformation(
        type='period-group',
        file_name_pattern="PEGR.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[PeriodGroupCode]','[Description]'],
        output_field_names=['[DataOwnerCode]','[PeriodGroupCode]','[Description]'],
        db_script="time-demand-group-schedules/import-period-group.sql"
    ),
    TransitDataTypeInformation(
        type='pegr-validity',
        file_name_pattern="PEGRVAL.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[OrganizationalUnitCode]','[PeriodGroupCode]','[ValidFrom]','[ValidThru]'],
        output_field_names=['[DataOwnerCode]','[OrganizationalUnitCode]','[PeriodGroupCode]','[ValidFrom]','[ValidThru]'],
        db_script="time-demand-group-schedules/import-period-group-validity.sql"
    ),

    TransitDataTypeInformation(
        type='specday',
        file_name_pattern="SPECDAY.TMI",
        input_field_names=['[Recordtype]', '[Version number]', '[Implicit]',
                           '[DataOwnerCode]', '[SpecificDayCode]', '[Name]',
                           '[Description]'],
        output_field_names=['[DataOwnerCode]', '[SpecificDayCode]', '[Name]',
                            '[Description]'],
        db_script="time-demand-group-schedules/import-specific-day.sql"
    ),
    TransitDataTypeInformation(
        type='exceptday',
        file_name_pattern="EXCOPDAY.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[OrganizationalUnitCode]','[ValidDate]','[DayTypeAsOn]','[SpecificDayCode]','[PeriodGroupCode]','[Description]'],
        output_field_names=['[DataOwnerCode]','[OrganizationalUnitCode]','[ValidDate]','[DayTypeAsOn]','[SpecificDayCode]','[PeriodGroupCode]','[Description]'],
        db_script="time-demand-group-schedules/import-exceptional-operating-day.sql"
    ),
    TransitDataTypeInformation(
        type='timetablevers',
        file_name_pattern="TIVE.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[OrganizationalUnitCode]','[TimetableVersionCode]','[PeriodGroupCode]','[SpecificDayCode]','[ValidFrom]','[TimetableVersionType]','[ValidThru]','[Description]'],
        output_field_names=['[DataOwnerCode]','[OrganizationalUnitCode]','[TimetableVersionCode]','[PeriodGroupCode]','[SpecificDayCode]','[ValidFrom]','[TimetableVersionType]','[ValidThru]','[Description]'],
        db_script="time-demand-group-schedules/import-timetable-version.sql"
    ),

    TransitDataTypeInformation(
        type='timdemgrp',
        file_name_pattern="TIMDEMGRP.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[TimeDemandGroupCode]'],
        output_field_names=['[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[TimeDemandGroupCode]'],
        db_script="time-demand-group-schedules/import-time-demand-group.sql"
    ),
    TransitDataTypeInformation(
        type="timdemrnt",
        file_name_pattern="TIMDEMRNT.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[TimeDemandGroupCode]','[TimingLinkOrder]','[UserStopCodeBegin]','[UserStopCodeEnd]','[TotalDriveTime]','[DriveTime]','[ExpectedDelay]','[LayOverTime]','[StopWaitTime]','[MinimumStopTime]'],
        output_field_names=['[DataOwnerCode]','[LinePlanningNumber]','[JourneyPatternCode]','[TimeDemandGroupCode]','[TimingLinkOrder]','[UserStopCodeBegin]','[UserStopCodeEnd]','[TotalDriveTime]','[DriveTime]','[ExpectedDelay]','[LayOverTime]','[StopWaitTime]','[MinimumStopTime]'],
        db_script="time-demand-group-schedules/import-time-demand-group-run-time.sql"
    ),
    TransitDataTypeInformation(
        type='pujo',
        file_name_pattern="PUJO.TMI",
        input_field_names=['[Recordtype]','[Version number]','[Implicit]','[DataOwnerCode]','[TimetableVersionCode]','[OrganizationalUnitCode]','[PeriodGroupCode]','[SpecificDayCode]','[DayType]','[LinePlanningNumber]','[JourneyNumber]','[TimeDemandGroupCode]','[JourneyPatternCode]','[DepartureTime]','[WheelChairAccessible]','[DataOwnerIsOperator]','[PlannedMonitored]','[ProductFormulaType]'],
        output_field_names=['[DataOwnerCode]','[TimetableVersionCode]','[OrganizationalUnitCode]','[PeriodGroupCode]','[SpecificDayCode]','[DayType]','[LinePlanningNumber]','[JourneyNumber]','[TimeDemandGroupCode]','[JourneyPatternCode]','[DepartureTime]','[WheelChairAccessible]','[DataOwnerIsOperator]','[PlannedMonitored]'],
        db_script="time-demand-group-schedules/import-public-journey.sql"
    )
]

journey_pass_types = [
    TransitDataTypeInformation(
        type='schedvers',
        file_name_pattern="SCHEDVERS.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[OrganizationalUnitCode]','[ScheduleCode]','[ScheduleTypeCode]','[ValidFrom]','[ValidThru]','[Description]'],
        output_field_names=['[DataOwnerCode]','[OrganizationalUnitCode]','[ScheduleCode]','[ScheduleTypeCode]','[ValidFrom]','[ValidThru]','[Description]'],
        db_script="pass/import-schedule-version.sql"
    ),
    TransitDataTypeInformation(
        type='oper-day',
        file_name_pattern="OPERDAY.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[OrganizationalUnitCode]','[ScheduleCode]','[ScheduleTypeCode]','[ValidDate]','[Description]'],
        output_field_names=['[DataOwnerCode]','[OrganizationalUnitCode]','[ScheduleCode]','[ScheduleTypeCode]','[ValidDate]','[Description]'],
        db_script="pass/import-operating-day.sql"
    ),
    TransitDataTypeInformation(
        type='pujopass',
        file_name_pattern="PUJOPASS.TMI",
        input_field_names=['[RecordType]','[VersionNumber]','[Implicit]','[DataOwnerCode]','[OrganizationalUnitCode]','[ScheduleCode]','[ScheduleTypeCode]','[LinePlanningNumber]','[JourneyNumber]','[StopOrder]','[JourneyPatternCode]','[UserStopCode]','[TargetArrivalTime]','[TargetDepartureTime]','[WheelChairAccessible]','[DataOwnerIsOperator]','[PlannedMonitored]','[ProductFormulaType]'],
        output_field_names=['[DataOwnerCode]','[OrganizationalUnitCode]','[ScheduleCode]','[ScheduleTypeCode]','[LinePlanningNumber]','[JourneyNumber]','[StopOrder]','[JourneyPatternCode]','[UserStopCode]','[TargetArrivalTime]','[TargetDepartureTime]','[WheelChairAccessible]','[DataOwnerIsOperator]','[PlannedMonitored]'],
        db_script="pass/import-public-journey-pass.sql"
    )
]


data_types_to_import = common_data_types + time_demand_group_types + journey_pass_types
for data in data_types_to_import:
    temp_file = merge_files_into_temp(data)
    call("psql -U larsstegman -d ovdata_db -v data=\"'%s'\" -f database-scripts/import/%s" % (temp_file, data.db_script), shell=True)
    remove('..' + temp_file)

call("psql -U larsstegman -d ovdata_db -f database-scripts/import/refresh-views.sql", shell=True)
