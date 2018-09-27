-- Source:
-- "Specificatie BISON, BISON Enumaraties en Tabellen, Koppelvlak overkoepelend,
-- versie 8.2.0.3, 12 april 2018. Table E1"
CREATE TYPE ovdata.DataOwnerCode AS
    ENUM('ARR',
         'VTN',
         'CXX',
         'GVB',
         'HTM',
         'RET',
         'NS',
         'SYNTUS',
         'QBUZZ',
         'EBS',
         'HTMBUZZ',
         'DELIJN',
         'TEC',
         'MIVB',
         'DOEKSEN',
         'WPD',
         'TESO',
         'WSF',
         'TCR',
         'FLIXBUS',
         'OUIBUS',
         'EUROLINES',
         'HTZ',
         'WTR',
         'ALGEMEEN',
         'DRECHTSTED',
         'GOVI',
         'RIG',
         'SABIMOS',
         'PRORAIL',
         'OPENOV',
         'CBSXXYYYY',
         'RWSaaaaaa',
         'INFRAbbbbb');

CREATE TYPE ovdata.UserStopType AS
    ENUM('PASSENGER',
         'BRIDGE',
         'FINANCIAL');

CREATE TYPE ovdata.TransportType AS
  ENUM('TRAIN',
       'BUS',
       'METRO',
       'TRAM',
       'BOAT');

CREATE TYPE ovdata.PointType AS
  ENUM('AG', 'AV', 'PL', 'RS', 'SP');

CREATE TYPE ovdata.Direction AS ENUM ('A', 'B');

CREATE TYPE ovdata.OrganizationalUnitType
  AS ENUM('BEDR', 'CCAR', 'LINE', 'LINEGR', 'VEST');

CREATE TYPE ovdata.WheelChairAccessibility
  AS ENUM ('ACCESSIBLE', 'NOTACCESSIBLE', 'UNKNOWN');
