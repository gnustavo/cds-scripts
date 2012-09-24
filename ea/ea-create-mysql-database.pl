#!/usr/bin/env perl

# This software is copyright (c) 2012 by CPqD <www.cpqd.com.br>.

# This is free software; you can redistribute it and/or modify it
# under the same terms as the Perl 5 programming language system
# itself.

use utf8;
use strict;
use warnings;
use open ':utf8';
use Getopt::Long;
use DBI;

use FindBin;
use lib ("$FindBin::Bin/../lib/perl");
use CDS::Utils;

# CONFIGURATION

# GROK COMMAND LINE
my $usage = "$0 [--verbose] [--dbhost=host] DBNAME\n";
my $Verbose;
my $DBHOST = 'cristal';
GetOptions(
    'verbose+' => \$Verbose,
    'dbhost=s' => \$DBHOST,
) or die $usage;

my $DBNAME = shift or die "$usage\nMissing DBNAME\n";
my $DSN    = "dbi:mysql:database=mysql;host=$DBHOST";

# MAIN

my ($dbuser, $dbpass) = get_credentials('dbuser', 'dbpass', prompt => 'MySQL admin');

my $eapass = genpasswd();

warn "Check if database $DBNAME doesn't exist...\n" if $Verbose;
{
    my $db = DBI->connect($DSN, $dbuser, $dbpass,
			  {RaiseError => 1, AutoCommit => 0, FetchHashKeyName => 'NAME_lc'})
	or die $DBNAME::errstr;
    die "Database $DBNAME already exists.\n"
	if @{$db->selectall_arrayref("select distinct db from db where db = '$DBNAME'")};
}

warn "Create database and user $DBNAME...\n" if $Verbose;
{
    open my $db, '|-', "mysql --user=$dbuser --password=$dbpass --host=$DBHOST"
	or die "Can't exec command mysql: $!\n";

    print $db <<"EOS" or die;
create database $DBNAME;
create user $DBNAME identified by '$eapass';
grant all on $DBNAME.* to $DBNAME\@'\%';
grant all on $DBNAME.* to $DBNAME\@'localhost';
EOS
    close $db;
}

warn "Run SQL in database $DBNAME...\n" if $Verbose;
{
    open my $db, '|-', "mysql -D $DBNAME -u $DBNAME -p'$eapass' --host=$DBHOST"
	or die "Can't exec command mysql: $!\n";
    while (<DATA>) {
	print $db or die;
    }
    close $db;
}

warn "Check number of tables created...\n" if $Verbose;
{
    my $n = `echo 'show tables' | mysql -u $DBNAME $DBNAME | wc -l`
	or die "Can't run 'show tables'\n";
    chomp $n;
    warn "WARN: Database should have 99 tables but has $n!"
	if $n != 99;

}

print <<EOS;
Data transfer finished.
Please, record and commit the following information:

  User: $DBNAME
  Password: $eapass
  Database: $DBNAME
  Connection String: "Driver=MySQL ODBC 5.1 Driver;SERVER=eadatabase;DataBase=$DBNAME;User=$DBNAME;Password=$eapass;Option=3;"

Use the above connection string to transfer the EAP to the database.
EOS

exit 0;

# Verificar se o script abaixo foi atualizado pela Sparx em
# http://www.sparxsystems.com/resources/corporate/.
# Verificado em 2012-06-06.


__DATA__
#------------------------------------------------
# Enterprise Architect Schema Script 
# DBMS:     MySQL InnoDB
# VERSION:  From 4.                         
# CREATED:  21/1/2010 			
# EA BUILD: 852	  
#------------------------------------------------

#
# Table structure for table `t_attribute`
#
DROP TABLE IF EXISTS `t_attribute`;
CREATE TABLE `t_attribute` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Name` varchar(255) NOT NULL,
  `Scope` varchar(50) DEFAULT NULL,
  `Stereotype` varchar(50) DEFAULT NULL,
  `Containment` varchar(50) DEFAULT NULL,
  `IsStatic` int(11) DEFAULT '0',
  `IsCollection` int(11) DEFAULT '0',
  `IsOrdered` int(11) DEFAULT '0',
  `AllowDuplicates` int(11) DEFAULT '0',
  `LowerBound` varchar(50) DEFAULT NULL,
  `UpperBound` varchar(50) DEFAULT NULL,
  `Container` varchar(50) DEFAULT NULL,
  `Notes` text,
  `Derived` char(1) DEFAULT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Pos` int(11) DEFAULT NULL,
  `GenOption` text,
  `Length` int(11) DEFAULT NULL,
  `Precision` int(11) DEFAULT NULL,
  `Scale` int(11) DEFAULT NULL,
  `Const` int(11) DEFAULT NULL,
  `Style` varchar(255) DEFAULT NULL,
  `Classifier` varchar(50) DEFAULT NULL,
  `Default` text,
  `Type` varchar(255) DEFAULT NULL,
  `ea_guid` varchar(40) NOT NULL,
  `StyleEx` text,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `ux_attribute_eaguid` (`ea_guid`),
  INDEX `ix_attribute_Name` (`Name`),
  INDEX `ix_attribute_Object_ID` (`Object_ID`),
  INDEX `ix_attribute_Classifier` (`Classifier`),
  INDEX `ix_attribute_Type` (`Type`)
) ENGINE=InnoDB;

#
# Table structure for table `t_attributeconstraints`
#

DROP TABLE IF EXISTS `t_attributeconstraints`;
CREATE TABLE `t_attributeconstraints` (
  `Object_ID` int(11) DEFAULT '0',
  `Constraint` varchar(255) NOT NULL,
  `AttName` varchar(255) DEFAULT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `Notes` text,
  `ID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Constraint`)
) ENGINE=InnoDB;

#
# Table structure for table `t_attributetag`
#

DROP TABLE IF EXISTS `t_attributetag`;
CREATE TABLE `t_attributetag` (
  `PropertyID` int(11) NOT NULL AUTO_INCREMENT,
  `ElementID` int(11) NOT NULL DEFAULT '0',
  `Property` varchar(255) DEFAULT NULL,
  `VALUE` varchar(255) DEFAULT NULL,
  `NOTES` text,
  `ea_guid` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`PropertyID`),
  INDEX `ix_attributetag_ElementID` (`ElementID`),
  INDEX `ix_attributetag_value` (`VALUE`)
) ENGINE=InnoDB;

#
# Table structure for table `t_authors`
#

DROP TABLE IF EXISTS `t_authors`;
CREATE TABLE `t_authors` (
  `AuthorName` varchar(255) NOT NULL,
  `Roles` varchar(255) DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`AuthorName`)
) ENGINE=InnoDB;

#
# Table structure for table `t_cardinality`
#

DROP TABLE IF EXISTS `t_cardinality`;
CREATE TABLE `t_cardinality` (
  `Cardinality` varchar(50) NOT NULL,
  PRIMARY KEY (`Cardinality`)
) ENGINE=InnoDB;

#
# Table structure for table `t_category`
#

DROP TABLE IF EXISTS `t_category`;
CREATE TABLE `t_category` (
  `CategoryID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `NOTES` text,
  PRIMARY KEY (`CategoryID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_clients`
#

DROP TABLE IF EXISTS `t_clients`;
CREATE TABLE `t_clients` (
  `Name` varchar(255) NOT NULL,
  `Organisation` varchar(255) DEFAULT NULL,
  `Phone1` varchar(50) DEFAULT NULL,
  `Phone2` varchar(50) DEFAULT NULL,
  `Mobile` varchar(50) DEFAULT NULL,
  `Fax` varchar(50) DEFAULT NULL,
  `Email` varchar(50) DEFAULT NULL,
  `Roles` varchar(255) DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=InnoDB;

#
# Table structure for table `t_complexitytypes`
#

DROP TABLE IF EXISTS `t_complexitytypes`;
CREATE TABLE `t_complexitytypes` (
  `Complexity` varchar(50) NOT NULL,
  `NumericWeight` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Complexity`),
  INDEX `ix_complexitytypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_connector`
#

DROP TABLE IF EXISTS `t_connector`;
CREATE TABLE `t_connector` (
  `Connector_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `Direction` varchar(50) DEFAULT NULL,
  `Notes` text,
  `Connector_Type` varchar(50) NOT NULL,
  `SubType` varchar(50) DEFAULT NULL,
  `SourceCard` varchar(50) DEFAULT NULL,
  `SourceAccess` varchar(50) DEFAULT NULL,
  `SourceElement` varchar(50) DEFAULT NULL,
  `DestCard` varchar(50) DEFAULT NULL,
  `DestAccess` varchar(50) DEFAULT NULL,
  `DestElement` varchar(50) DEFAULT NULL,
  `SourceRole` varchar(255) DEFAULT NULL,
  `SourceRoleType` varchar(50) DEFAULT NULL,
  `SourceRoleNote` text,
  `SourceContainment` varchar(50) DEFAULT NULL,
  `SourceIsAggregate` int(11) DEFAULT '0',
  `SourceIsOrdered` int(11) DEFAULT '0',
  `SourceQualifier` varchar(50) DEFAULT NULL,
  `DestRole` varchar(255) DEFAULT NULL,
  `DestRoleType` varchar(50) DEFAULT NULL,
  `DestRoleNote` text,
  `DestContainment` varchar(50) DEFAULT NULL,
  `DestIsAggregate` int(11) DEFAULT '0',
  `DestIsOrdered` int(11) DEFAULT '0',
  `DestQualifier` varchar(50) DEFAULT NULL,
  `Start_Object_ID` int(11) NOT NULL DEFAULT '0',
  `End_Object_ID` int(11) NOT NULL DEFAULT '0',
  `Top_Start_Label` varchar(50) DEFAULT NULL,
  `Top_Mid_Label` varchar(50) DEFAULT NULL,
  `Top_End_Label` varchar(50) DEFAULT NULL,
  `Btm_Start_Label` varchar(50) DEFAULT NULL,
  `Btm_Mid_Label` varchar(50) DEFAULT NULL,
  `Btm_End_Label` varchar(50) DEFAULT NULL,
  `Start_Edge` int(11) DEFAULT '0',
  `End_Edge` int(11) DEFAULT '0',
  `PtStartX` int(11) DEFAULT '0',
  `PtStartY` int(11) DEFAULT '0',
  `PtEndX` int(11) DEFAULT '0',
  `PtEndY` int(11) DEFAULT '0',
  `SeqNo` int(11) DEFAULT '0',
  `HeadStyle` int(11) DEFAULT '0',
  `LineStyle` int(11) DEFAULT '0',
  `RouteStyle` int(11) DEFAULT '0',
  `IsBold` int(11) DEFAULT '0',
  `LineColor` int(11) DEFAULT '0',
  `Stereotype` varchar(50) DEFAULT NULL,
  `VirtualInheritance` char(1) DEFAULT NULL,
  `LinkAccess` varchar(50) DEFAULT NULL,
  `PDATA1` varchar(255) DEFAULT NULL,
  `PDATA2` text,
  `PDATA3` varchar(255) DEFAULT NULL,
  `PDATA4` varchar(255) DEFAULT NULL,
  `PDATA5` text,
  `DiagramID` int(11) NOT NULL DEFAULT '0',
  `ea_guid` varchar(40) NOT NULL,
  `SourceConstraint` varchar(255) DEFAULT NULL,
  `DestConstraint` varchar(255) DEFAULT NULL,
  `SourceIsNavigable` int(11) DEFAULT NULL,
  `DestIsNavigable` int(11) DEFAULT NULL,
  `IsRoot` int(11) DEFAULT NULL,
  `IsLeaf` int(11) DEFAULT NULL,
  `IsSpec` int(11) DEFAULT NULL,
  `SourceChangeable` varchar(12) DEFAULT NULL,
  `DestChangeable` varchar(12) DEFAULT NULL,
  `SourceTS` varchar(12) DEFAULT NULL,
  `DestTS` varchar(12) DEFAULT NULL,
  `StateFlags` text,
  `ActionFlags` varchar(255) DEFAULT NULL,
  `IsSignal` int(11) DEFAULT NULL,
  `IsStimulus` int(11) DEFAULT NULL,
  `DispatchAction` varchar(255) DEFAULT NULL,
  `Target2` int(11) DEFAULT NULL,
  `StyleEx` text,
  `SourceStereotype` varchar(255) DEFAULT NULL,
  `DestStereotype` varchar(255) DEFAULT NULL,
  `SourceStyle` text,
  `DestStyle` text,
  `EventFlags` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Connector_ID`),
  UNIQUE INDEX `IDX_GUID` (`ea_guid`),
  UNIQUE INDEX `Connector_ID` (`Connector_ID`),
  INDEX `ix_connector_Connector_Type` (`Connector_Type`),
  INDEX `ix_connector_DiagramID` (`DiagramID`),
  INDEX `ix_connector_End_Object_ID` (`End_Object_ID`),
  INDEX `ix_connector_Start_Object_ID` (`Start_Object_ID`),
  INDEX `ix_connector_SeqNo` (`SeqNo`),
  INDEX `ix_connector_endobjid_connid` (`End_Object_ID`,`Connector_ID`),
  INDEX `ix_connector_startobjid_connid` (`Start_Object_ID`,`Connector_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_connectorconstraint`
#

DROP TABLE IF EXISTS `t_connectorconstraint`;
CREATE TABLE `t_connectorconstraint` (
  `ConnectorID` int(11) NOT NULL DEFAULT '0',
  `Constraint` varchar(255) NOT NULL,
  `ConstraintType` varchar(50) DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`ConnectorID`,`Constraint`),
  INDEX `ObjectConstraintConstraint` (`Constraint`),
  INDEX `ObjectID` (`ConnectorID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_connectortag`
#

DROP TABLE IF EXISTS `t_connectortag`;
CREATE TABLE `t_connectortag` (
  `PropertyID` int(11) NOT NULL AUTO_INCREMENT,
  `ElementID` int(11) NOT NULL DEFAULT '0',
  `Property` varchar(255) DEFAULT NULL,
  `VALUE` varchar(255) DEFAULT NULL,
  `NOTES` text,
  `ea_guid` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`PropertyID`),
  INDEX `ix_connectortag_ElementID` (`ElementID`),
  INDEX `ix_connectortag_Property` (`Property`),
  INDEX `ix_connectortag_VALUE` (`VALUE`)
) ENGINE=InnoDB;

#
# Table structure for table `t_connectortypes`
#

DROP TABLE IF EXISTS `t_connectortypes`;
CREATE TABLE `t_connectortypes` (
  `Connector_Type` varchar(50) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Connector_Type`)
) ENGINE=InnoDB;

#
# Table structure for table `t_constants`
#

DROP TABLE IF EXISTS `t_constants`;
CREATE TABLE `t_constants` (
  `ConstantName` varchar(50) NOT NULL,
  `ConstantValue` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ConstantName`)
) ENGINE=InnoDB;

#
# Table structure for table `t_constrainttypes`
#

DROP TABLE IF EXISTS `t_constrainttypes`;
CREATE TABLE `t_constrainttypes` (
  `Constraint` varchar(16) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`Constraint`)
) ENGINE=InnoDB;

#
# Table structure for table `t_datatypes`
#

DROP TABLE IF EXISTS `t_datatypes`;
CREATE TABLE `t_datatypes` (
  `Type` varchar(50) NOT NULL,
  `ProductName` varchar(50) NOT NULL,
  `DataType` varchar(50) NOT NULL,
  `Size` int(11) DEFAULT NULL,
  `MaxLen` int(11) DEFAULT NULL,
  `MaxPrec` int(11) DEFAULT NULL,
  `MaxScale` int(11) DEFAULT '0',
  `DefaultLen` int(11) DEFAULT NULL,
  `DefaultPrec` int(11) DEFAULT NULL,
  `DefaultScale` int(11) DEFAULT NULL,
  `User` int(11) DEFAULT NULL,
  `PDATA1` varchar(255) DEFAULT NULL,
  `PDATA2` varchar(255) DEFAULT NULL,
  `PDATA3` varchar(255) DEFAULT NULL,
  `PDATA4` varchar(255) DEFAULT NULL,
  `HasLength` varchar(50) DEFAULT NULL,
  `GenericType` varchar(255) DEFAULT NULL,
  `DatatypeID` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`DatatypeID`),
  INDEX `ix_datatypes_ProductName` (`ProductName`),
  INDEX `ix_datatypes_Datatype` (`Datatype`)
) ENGINE=InnoDB;

#
# Table structure for table `t_diagram`
#

DROP TABLE IF EXISTS `t_diagram`;
CREATE TABLE `t_diagram` (
  `Diagram_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Package_ID` int(11) NOT NULL DEFAULT '1',
  `ParentID` int(11) NOT NULL DEFAULT '0',
  `Diagram_Type` varchar(50) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Version` varchar(50) DEFAULT '1.0',
  `Author` varchar(255) DEFAULT NULL,
  `ShowDetails` int(11) DEFAULT '0',
  `Notes` text,
  `Stereotype` varchar(50) DEFAULT NULL,
  `AttPub` int(11) DEFAULT NULL,
  `AttPri` int(11) DEFAULT NULL,
  `AttPro` int(11) DEFAULT NULL,
  `Orientation` char(1) DEFAULT 'P',
  `cx` int(11) DEFAULT '0',
  `cy` int(11) DEFAULT '0',
  `Scale` int(11) DEFAULT '100',
  `CreatedDate` date DEFAULT NULL,
  `ModifiedDate` date DEFAULT NULL,
  `HTMLPath` varchar(255) DEFAULT NULL,
  `ShowForeign` int(11) DEFAULT NULL,
  `ShowBorder` int(11) DEFAULT NULL,
  `ShowPackageContents` int(11) DEFAULT NULL,
  `PDATA` varchar(255) DEFAULT NULL,
  `Locked` int(11) DEFAULT NULL,
  `ea_guid` varchar(40) NOT NULL,
  `TPos` int(11) DEFAULT NULL,
  `Swimlanes` varchar(255) DEFAULT NULL,
  `StyleEx` text,
  PRIMARY KEY (`Diagram_ID`),
  UNIQUE INDEX `ux_diagram_eaguid` (`ea_guid`),
  UNIQUE INDEX `ux_diagram_Diagram_ID` (`Diagram_ID`),
  INDEX `ix_diagram_Diagram_Type` (`Diagram_Type`),
  INDEX `ix_diagram_Package_ID` (`Package_ID`),
  INDEX `ix_diagram_ParentID` (`ParentID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_diagramlinks`
#

DROP TABLE IF EXISTS `t_diagramlinks`;
CREATE TABLE `t_diagramlinks` (
  `DiagramID` int(11) NOT NULL DEFAULT '0',
  `ConnectorID` int(11) NOT NULL DEFAULT '0',
  `Geometry` text,
  `Style` varchar(255) DEFAULT NULL,
  `Hidden` int(11) DEFAULT NULL,
  `Path` varchar(255) DEFAULT NULL,
  `Instance_ID` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`Instance_ID`),
  INDEX `ix_diagramlinks_DiagramID` (`DiagramID`),
  INDEX `ix_diagramlinks_ConnectorID` (`ConnectorID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_diagramobjects`
#

DROP TABLE IF EXISTS `t_diagramobjects`;
CREATE TABLE `t_diagramobjects` (
  `Diagram_ID` int(11) NOT NULL DEFAULT '0',
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `RectTop` int(11) DEFAULT '0',
  `RectLeft` int(11) DEFAULT '0',
  `RectRight` int(11) DEFAULT '0',
  `RectBottom` int(11) DEFAULT '0',
  `Sequence` int(11) DEFAULT '0',
  `ObjectStyle` varchar(255) DEFAULT NULL,
  `Instance_ID` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`Instance_ID`),
  INDEX `ix_diagramobjects_DiagramID` (`Diagram_ID`),
  INDEX `ix_diagramobjects_ObjectID` (`Object_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_diagramtypes`
#

DROP TABLE IF EXISTS `t_diagramtypes`;
CREATE TABLE `t_diagramtypes` (
  `Diagram_Type` varchar(50) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Package_ID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Diagram_Type`),
  INDEX `ix_diagramtypes_PackageID` (`Package_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_document`
#

DROP TABLE IF EXISTS `t_document`;
CREATE TABLE `t_document` (
  `DocID` varchar(40) NOT NULL,
  `DocName` varchar(100) DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  `Style` varchar(255) DEFAULT NULL,
  `ElementID` varchar(40) NOT NULL,
  `ElementType` varchar(50) NOT NULL,
  `StrContent` text,
  `BinContent` longblob,
  `DocType` varchar(100) DEFAULT NULL,
  `Author` varchar(255) DEFAULT NULL,
  `Version` varchar(50) DEFAULT NULL,
  `IsActive` int(11) DEFAULT '1',
  `Sequence` int(11) DEFAULT '0',
  `DocDate` datetime DEFAULT NULL,
  PRIMARY KEY (`DocID`),
  INDEX `ix_document_ElementID` (`ElementID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_ecf`
#

DROP TABLE IF EXISTS `t_ecf`;
CREATE TABLE `t_ecf` (
  `ECFID` varchar(12) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `Weight` double NOT NULL DEFAULT '1',
  `Value` double DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ECFID`),
  INDEX `ix_ecf_Weight` (`Weight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_efforttypes`
#

DROP TABLE IF EXISTS `t_efforttypes`;
CREATE TABLE `t_efforttypes` (
  `EffortType` varchar(12) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '0',
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`EffortType`),
  INDEX `ix_efforttypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB; 

#
# Table structure for table `t_files`
#

DROP TABLE IF EXISTS `t_files`;
CREATE TABLE `t_files` (
  `FileID` varchar(50) NOT NULL,
  `AppliesTo` varchar(50) NOT NULL,
  `Category` varchar(100) NOT NULL,
  `Name` varchar(150) NOT NULL,
  `File` varchar(255) DEFAULT NULL,
  `Notes` text,
  `FileDate` datetime DEFAULT NULL,
  `FileSize` int(11) DEFAULT NULL,
  PRIMARY KEY (`FileID`)
) ENGINE=InnoDB;


#
# Table structure for table `t_genopt`
#

DROP TABLE IF EXISTS `t_genopt`;
CREATE TABLE `t_genopt` (
  `AppliesTo` varchar(12) DEFAULT NULL,
  `Option` text
) ENGINE=InnoDB;

#
# Table structure for table `t_glossary`
#

DROP TABLE IF EXISTS `t_glossary`;
CREATE TABLE `t_glossary` (
  `Term` varchar(255) NOT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `Meaning` text,
  `GlossaryID` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`Term`),
  INDEX `ix_glossary_GlossaryID` (`GlossaryID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_html`
#

DROP TABLE IF EXISTS `t_html`;
CREATE TABLE `t_html` (
  `Type` varchar(50) DEFAULT NULL,
  `Template` text
) ENGINE=InnoDB;

#
# Table structure for table `t_image`
#

DROP TABLE IF EXISTS `t_image`;
CREATE TABLE `t_image` (
  `ImageID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `Image` longblob,
  PRIMARY KEY (`ImageID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_implement`
#

DROP TABLE IF EXISTS `t_implement`;
CREATE TABLE `t_implement` (
  `Type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB;

#
# Table structure for table `t_issues`
#

DROP TABLE IF EXISTS `t_issues`;
CREATE TABLE `t_issues` (
  `Issue` varchar(255) DEFAULT NULL,
  `IssueDate` datetime DEFAULT '0000-00-00 00:00:00',
  `Owner` varchar(255) DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `Notes` text,
  `Resolver` varchar(255) DEFAULT NULL,
  `DateResolved` datetime DEFAULT NULL,
  `Resolution` text,
  `IssueID` int(11) NOT NULL AUTO_INCREMENT,
  `Category` varchar(255) DEFAULT NULL,
  `Priority` varchar(50) DEFAULT NULL,
  `Severity` varchar(50) DEFAULT NULL,
  `IssueType` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`IssueID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_lists`
#

DROP TABLE IF EXISTS `t_lists`;
CREATE TABLE `t_lists` (
  `ListID` varchar(50) NOT NULL,
  `Category` varchar(100) NOT NULL,
  `Name` varchar(150) NOT NULL,
  `NVal` int(11) DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`ListID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_mainttypes`
#

DROP TABLE IF EXISTS `t_mainttypes`;
CREATE TABLE `t_mainttypes` (
  `MaintType` varchar(12) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '1',
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`MaintType`),
  INDEX `ix_mainttypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_method`
#

DROP TABLE IF EXISTS `t_method`;
CREATE TABLE `t_method` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Name` varchar(255) NOT NULL,
  `Scope` varchar(50) DEFAULT NULL,
  `Type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Object_ID`,`Name`),
  INDEX `ix_method_Object_ID` (`Object_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_metrictypes`
#

DROP TABLE IF EXISTS `t_metrictypes`;
CREATE TABLE `t_metrictypes` (
  `Metric` varchar(12) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '1',
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Metric`),
  INDEX `ix_metrictypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_object`
#

DROP TABLE IF EXISTS `t_object`;
CREATE TABLE `t_object` (
  `Object_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Object_Type` varchar(255) DEFAULT NULL,
  `Diagram_ID` int(11) DEFAULT '0',
  `Name` varchar(255) DEFAULT NULL,
  `Alias` varchar(255) DEFAULT NULL,
  `Author` varchar(255) DEFAULT NULL,
  `Version` varchar(50) DEFAULT '1.0',
  `Note` text,
  `Package_ID` int(11) NOT NULL DEFAULT '0',
  `Stereotype` varchar(255) DEFAULT NULL,
  `NType` int(11) DEFAULT '0',
  `Complexity` varchar(50) DEFAULT '2',
  `Effort` int(11) DEFAULT '0',
  `Style` varchar(255) DEFAULT NULL,
  `Backcolor` int(11) DEFAULT '0',
  `BorderStyle` int(11) DEFAULT '0',
  `BorderWidth` int(11) DEFAULT '0',
  `Fontcolor` int(11) DEFAULT '0',
  `Bordercolor` int(11) DEFAULT '0',
  `CreatedDate` datetime DEFAULT NULL,
  `ModifiedDate` datetime DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `Abstract` char(1) DEFAULT NULL,
  `Tagged` int(11) DEFAULT '0',
  `PDATA1` varchar(255) DEFAULT NULL,
  `PDATA2` text,
  `PDATA3` text,
  `PDATA4` text,
  `PDATA5` varchar(255) DEFAULT NULL,
  `Concurrency` varchar(50) DEFAULT NULL,
  `Visibility` varchar(50) DEFAULT NULL,
  `Persistence` varchar(50) DEFAULT NULL,
  `Cardinality` varchar(50) DEFAULT NULL,
  `GenType` varchar(50) DEFAULT NULL,
  `GenFile` varchar(255) DEFAULT NULL,
  `Header1` text,
  `Header2` text,
  `Phase` varchar(50) DEFAULT NULL,
  `Scope` varchar(25) DEFAULT NULL,
  `GenOption` text,
  `GenLinks` text,
  `Classifier` int(11) DEFAULT NULL,
  `ea_guid` varchar(40) NOT NULL,
  `ParentID` int(11) DEFAULT NULL,
  `RunState` text,
  `Classifier_guid` varchar(40) DEFAULT NULL,
  `TPos` int(11) DEFAULT NULL,
  `IsRoot` int(11) DEFAULT NULL,
  `IsLeaf` int(11) DEFAULT NULL,
  `IsSpec` int(11) DEFAULT NULL,
  `IsActive` int(11) DEFAULT NULL,
  `StateFlags` varchar(255) DEFAULT NULL,
  `PackageFlags` varchar(255) DEFAULT NULL,
  `Multiplicity` varchar(50) DEFAULT NULL,
  `StyleEx` text,
  `ActionFlags` varchar(255) DEFAULT NULL,
  `EventFlags` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Object_ID`),
  UNIQUE INDEX `ux_object_eaguid` (`ea_guid`),
  INDEX `ix_object_Package_ID` (`Package_ID`),
  INDEX `ix_object_Object_Type` (`Object_Type`),  
  INDEX `ix_object_Classifier` (`Classifier`),
  INDEX `ix_object_EventFlags` (`EventFlags`),
  INDEX `ix_object_Classifier_guid` (`Classifier_guid`),
  INDEX `ix_object_Name` (`Name`),
  INDEX `ix_object_NType` (`NType`),  
  INDEX `ix_object_ParentID` (`ParentID`),
  INDEX `ix_object_PDATA1` (`PDATA1`),
  INDEX `ix_object_PckgID_PD1_Classifier` (`Package_ID`,`PDATA1`,`Classifier`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectconstraint`
#

DROP TABLE IF EXISTS `t_objectconstraint`;
CREATE TABLE `t_objectconstraint` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Constraint` varchar(255) NOT NULL,
  `ConstraintType` varchar(30) NOT NULL,
  `Weight` double DEFAULT NULL,
  `Notes` text,
  `Status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Object_ID`,`ConstraintType`,`Constraint`),
  INDEX `ix_objectconstraint_Constraint` (`Constraint`),
  INDEX `ix_objectconstraint_ObjectID` (`Object_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objecteffort`
#

DROP TABLE IF EXISTS `t_objecteffort`;
CREATE TABLE `t_objecteffort` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Effort` varchar(255) NOT NULL,
  `EffortType` varchar(12) DEFAULT NULL,
  `EValue` double DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`Object_ID`,`Effort`),
  INDEX `ix_objecteffort_ObjectID` (`Object_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectfiles`
#

DROP TABLE IF EXISTS `t_objectfiles`;
CREATE TABLE `t_objectfiles` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `FileName` varchar(255) NOT NULL,
  `Type` varchar(50) DEFAULT NULL,
  `Note` text,
  `FileSize` varchar(255) DEFAULT NULL,
  `FileDate` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Object_ID`,`FileName`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectmetrics`
#

DROP TABLE IF EXISTS `t_objectmetrics`;
CREATE TABLE `t_objectmetrics` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Metric` varchar(255) NOT NULL,
  `MetricType` varchar(12) NOT NULL,
  `EValue` double DEFAULT '1',
  `Notes` text,
  PRIMARY KEY (`Object_ID`,`Metric`),
  INDEX `ix_objectmetrics_MetricType` (`MetricType`),
  INDEX `ix_objectmetrics_ObjectID` (`Object_ID`),
  INDEX `ix_objectmetrics_Metric` (`Metric`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectproblems`
#

DROP TABLE IF EXISTS `t_objectproblems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `t_objectproblems` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Problem` varchar(255) NOT NULL,
  `ProblemType` varchar(255) NOT NULL,
  `DateReported` date DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `ProblemNotes` text,
  `ReportedBy` varchar(255) DEFAULT NULL,
  `ResolvedBy` varchar(255) DEFAULT NULL,
  `DateResolved` date DEFAULT NULL,
  `Version` varchar(50) DEFAULT NULL,
  `ResolverNotes` text,
  `Priority` varchar(50) DEFAULT NULL,
  `Severity` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Object_ID`,`ProblemType`,`Problem`),
  INDEX `ix_objectproblems_Object_ID` (`Object_ID`),
  INDEX `ix_objectproblems_Problem` (`Problem`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectproperties`
#

DROP TABLE IF EXISTS `t_objectproperties`;
CREATE TABLE `t_objectproperties` (
  `PropertyID` int(11) NOT NULL AUTO_INCREMENT,
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Property` varchar(255) DEFAULT NULL,
  `Value` varchar(255) DEFAULT NULL,
  `Notes` text,
  `ea_guid` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`PropertyID`),
  INDEX `ix_objectproperties_Object_ID` (`Object_ID`),
  INDEX `ix_objectproperties_Value` (`Value`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectrequires`
#

DROP TABLE IF EXISTS `t_objectrequires`;
CREATE TABLE `t_objectrequires` (
  `ReqID` int(11) NOT NULL AUTO_INCREMENT,
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Requirement` varchar(255) DEFAULT NULL,
  `ReqType` varchar(255) DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `Notes` text,
  `Stability` varchar(50) DEFAULT NULL,
  `Difficulty` varchar(50) DEFAULT NULL,
  `Priority` varchar(50) DEFAULT NULL,
  `LastUpdate` varchar(19) DEFAULT NULL,
  PRIMARY KEY (`ReqID`),
  INDEX `ix_objectrequires_Object_ID` (`Object_ID`),
  INDEX `ix_objectrequires_Requirement` (`Requirement`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectresource`
#

DROP TABLE IF EXISTS `t_objectresource`;
CREATE TABLE `t_objectresource` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Resource` varchar(255) NOT NULL,
  `Role` varchar(255) NOT NULL,
  `Time` double DEFAULT NULL,
  `Notes` text,
  `PercentComplete` smallint(6) DEFAULT '0',
  `DateStart` date DEFAULT NULL,
  `DateEnd` date DEFAULT NULL,
  `History` text,
  `ExpectedHours` int(11) DEFAULT '0',
  `ActualHours` int(11) DEFAULT '0',
  PRIMARY KEY (`Object_ID`,`Resource`,`Role`),
  INDEX `ix_objectresource_ObjectID` (`Object_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectrisks`
#

DROP TABLE IF EXISTS `t_objectrisks`;
CREATE TABLE `t_objectrisks` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Risk` varchar(255) NOT NULL,
  `RiskType` varchar(12) DEFAULT NULL,
  `EValue` double DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`Object_ID`,`Risk`),
  INDEX `ix_objectrisks_ObjectID` (`Object_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objectscenarios`
#

DROP TABLE IF EXISTS `t_objectscenarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `t_objectscenarios` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Scenario` varchar(255) NOT NULL,
  `ScenarioType` varchar(12) DEFAULT NULL,
  `EValue` double DEFAULT NULL,
  `Notes` text,
  `ea_guid` varchar(40) NOT NULL,
  `XMLContent` text,
  PRIMARY KEY (`Object_ID`,`Scenario`),
  INDEX `ix_objectscenarios_Object_ID` (`Object_ID`),
  INDEX `ix_objectscenarios_idevalscen` (`Object_ID`,`EValue`,`Scenario`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objecttests`
#

DROP TABLE IF EXISTS `t_objecttests`;
CREATE TABLE `t_objecttests` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Test` varchar(255) NOT NULL,
  `TestClass` int(11) NOT NULL DEFAULT '0',
  `TestType` varchar(50) DEFAULT NULL,
  `Notes` text,
  `InputData` text,
  `AcceptanceCriteria` text,
  `Status` varchar(32) DEFAULT NULL,
  `DateRun` date DEFAULT NULL,
  `Results` text,
  `RunBy` varchar(255) DEFAULT NULL,
  `CheckBy` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Object_ID`,`Test`,`TestClass`),
  INDEX `ix_objecttests_ObjectID` (`Object_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objecttrx`
#

DROP TABLE IF EXISTS `t_objecttrx`;
CREATE TABLE `t_objecttrx` (
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `TRX` varchar(255) NOT NULL,
  `TRXType` varchar(12) NOT NULL,
  `Weight` double DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`Object_ID`,`TRXType`,`TRX`),
  INDEX `ix_objecttrx_TRX` (`TRX`),
  INDEX `ix_objecttrx_ObjectID` (`Object_ID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_objecttypes`
#

DROP TABLE IF EXISTS `t_objecttypes`;
CREATE TABLE `t_objecttypes` (
  `Object_Type` varchar(50) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `DesignObject` int(11) DEFAULT NULL,
  `ImageID` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Object_Type`),
  INDEX `ix_objecttypes_ImageID` (`ImageID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_ocf`
#

DROP TABLE IF EXISTS `t_ocf`;
CREATE TABLE `t_ocf` (
  `ObjectType` varchar(50) DEFAULT NULL,
  `ComplexityWeight` double DEFAULT NULL
) ENGINE=InnoDB;

#
# Table structure for table `t_operation`
#

DROP TABLE IF EXISTS `t_operation`;
CREATE TABLE `t_operation` (
  `OperationID` int(11) NOT NULL AUTO_INCREMENT,
  `Object_ID` int(11) NOT NULL DEFAULT '0',
  `Name` varchar(255) NOT NULL,
  `Scope` varchar(50) DEFAULT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `ReturnArray` char(1) DEFAULT NULL,
  `Stereotype` varchar(50) DEFAULT NULL,
  `IsStatic` char(1) DEFAULT NULL,
  `Concurrency` varchar(50) DEFAULT NULL,
  `Notes` text,
  `Behaviour` text,
  `Abstract` char(1) DEFAULT NULL,
  `GenOption` text,
  `Synchronized` char(1) DEFAULT NULL,
  `Pos` int(11) DEFAULT NULL,
  `Const` int(11) DEFAULT NULL,
  `Style` varchar(255) DEFAULT NULL,
  `Pure` int(11) DEFAULT NULL,
  `Throws` varchar(255) DEFAULT NULL,
  `Classifier` varchar(50) DEFAULT NULL,
  `Code` text,
  `IsRoot` int(11) DEFAULT NULL,
  `IsLeaf` int(11) DEFAULT NULL,
  `IsQuery` int(11) DEFAULT NULL,
  `StateFlags` varchar(255) DEFAULT NULL,
  `ea_guid` varchar(50) NOT NULL,
  `StyleEx` text,
  PRIMARY KEY (`OperationID`),
  UNIQUE INDEX `ux_operation_ea_guid` (`ea_guid`),
  INDEX `ix_operation_Name` (`Name`),
  INDEX `ix_operation_Object_ID` (`Object_ID`),
  INDEX `ix_operation_Classifier` (`Classifier`)
) ENGINE=InnoDB;

#
# Table structure for table `t_operationparams`
#

DROP TABLE IF EXISTS `t_operationparams`;
CREATE TABLE `t_operationparams` (
  `OperationID` int(11) NOT NULL DEFAULT '0',
  `Name` varchar(255) NOT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `Default` varchar(255) DEFAULT NULL,
  `Notes` text,
  `Pos` int(11) NOT NULL DEFAULT '0',
  `Const` int(11) DEFAULT NULL,
  `Style` varchar(255) DEFAULT NULL,
  `Kind` varchar(12) DEFAULT NULL,
  `Classifier` varchar(50) DEFAULT NULL,
  `ea_guid` varchar(50) NOT NULL,
  `StyleEx` text,
  PRIMARY KEY (`OperationID`,`Name`),
  UNIQUE INDEX `ix_operationparams_ea_guid` (`ea_guid`),
  INDEX `ix_operationparams_OperationID` (`OperationID`),
  INDEX `ix_operationparams_OpID_Pos` (`OperationID`,`Pos`),
  INDEX `ix_operationparams_Classifier` (`Classifier`)
) ENGINE=InnoDB;

#
# Table structure for table `t_operationposts`
#

DROP TABLE IF EXISTS `t_operationposts`;
CREATE TABLE `t_operationposts` (
  `OperationID` int(11) NOT NULL DEFAULT '0',
  `PostCondition` varchar(255) NOT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`OperationID`,`PostCondition`),
  INDEX `ix_operationposts_OperationID` (`OperationID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_operationpres`
#

DROP TABLE IF EXISTS `t_operationpres`;
CREATE TABLE `t_operationpres` (
  `OperationID` int(11) NOT NULL DEFAULT '0',
  `PreCondition` varchar(255) NOT NULL,
  `Type` varchar(50) DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`OperationID`,`PreCondition`),
  INDEX `ix_operationpres_OperationID` (`OperationID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_operationtag`
#

DROP TABLE IF EXISTS `t_operationtag`;
CREATE TABLE `t_operationtag` (
  `PropertyID` int(11) NOT NULL AUTO_INCREMENT,
  `ElementID` int(11) NOT NULL DEFAULT '0',
  `Property` varchar(255) DEFAULT NULL,
  `VALUE` varchar(255) DEFAULT NULL,
  `NOTES` text,
  `ea_guid` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`PropertyID`),
  INDEX `ix_operationtag_ElementID` (`ElementID`),
  INDEX `ix_operationtag_VALUE` (`VALUE`)
) ENGINE=InnoDB;

#
# Table structure for table `t_package`
#

DROP TABLE IF EXISTS `t_package`;
CREATE TABLE `t_package` (
  `Package_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `Parent_ID` int(11) NOT NULL DEFAULT '0',
  `CreatedDate` datetime DEFAULT NULL,
  `ModifiedDate` datetime DEFAULT NULL,
  `Notes` text,
  `ea_guid` varchar(40) NOT NULL,
  `XMLPath` varchar(255) DEFAULT NULL,
  `IsControlled` int(11) DEFAULT NULL,
  `LastLoadDate` datetime DEFAULT NULL,
  `LastSaveDate` datetime DEFAULT NULL,
  `Version` varchar(50) DEFAULT NULL,
  `Protected` int(11) DEFAULT NULL,
  `PkgOwner` varchar(255) DEFAULT NULL,
  `UMLVersion` varchar(50) DEFAULT NULL,
  `UseDTD` int(11) DEFAULT NULL,
  `LogXML` int(11) DEFAULT NULL,
  `CodePath` varchar(255) DEFAULT NULL,
  `Namespace` varchar(50) DEFAULT NULL,
  `TPos` int(11) DEFAULT NULL,
  `PackageFlags` varchar(255) DEFAULT NULL,
  `BatchSave` int(11) DEFAULT '0',
  `BatchLoad` int(11) DEFAULT '0',
  PRIMARY KEY (`Package_ID`),
  UNIQUE INDEX `ux_package_ea_guid` (`ea_guid`),
  INDEX `ix_package_ParentID` (`Parent_ID`),
  INDEX `ix_package_Name` (`Name`)
) ENGINE=InnoDB;

#
# Table structure for table `t_palette`
#

DROP TABLE IF EXISTS `t_palette`;
CREATE TABLE `t_palette` (
  `PaletteID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `Type` varchar(255) DEFAULT NULL,
  INDEX `PaletteID` (`PaletteID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_paletteitem`
#

DROP TABLE IF EXISTS `t_paletteitem`;
CREATE TABLE `t_paletteitem` (
  `PaletteID` int(11) DEFAULT NULL,
  `ItemID` int(11) DEFAULT NULL
) ENGINE=InnoDB;

#
# Table structure for table `t_phase`
#

DROP TABLE IF EXISTS `t_phase`;
CREATE TABLE `t_phase` (
  `PhaseID` varchar(40) NOT NULL,
  `PhaseName` varchar(100) NOT NULL,
  `PhaseNotes` text,
  `PhaseStyle` varchar(255) DEFAULT NULL,
  `StartDate` datetime DEFAULT NULL,
  `EndDate` datetime DEFAULT NULL,
  `PhaseContent` text,
  PRIMARY KEY (`PhaseID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_primitives`
#

DROP TABLE IF EXISTS `t_primitives`;
CREATE TABLE `t_primitives` (
  `Datatype` varchar(50) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Datatype`)
) ENGINE=InnoDB;

#
# Table structure for table `t_problemtypes`
#

DROP TABLE IF EXISTS `t_problemtypes`;
CREATE TABLE `t_problemtypes` (
  `ProblemType` varchar(12) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '1',
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ProblemType`),
  INDEX `ix_problemtypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_projectroles`
#

DROP TABLE IF EXISTS `t_projectroles`;
CREATE TABLE `t_projectroles` (
  `Role` varchar(255) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`Role`)
) ENGINE=InnoDB;

#
# Table structure for table `t_propertytypes`
#

DROP TABLE IF EXISTS `t_propertytypes`;
CREATE TABLE `t_propertytypes` (
  `Property` varchar(50) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `Notes` text,
  PRIMARY KEY (`Property`)
) ENGINE=InnoDB;

#
# Table structure for table `t_requiretypes`
#

DROP TABLE IF EXISTS `t_requiretypes`;
CREATE TABLE `t_requiretypes` (
  `Requirement` varchar(12) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '1',
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Requirement`),
  INDEX `ix_requiretypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_resources`
#

DROP TABLE IF EXISTS `t_resources`;
CREATE TABLE `t_resources` (
  `Name` varchar(255) NOT NULL,
  `Organisation` varchar(255) DEFAULT NULL,
  `Phone1` varchar(50) DEFAULT NULL,
  `Phone2` varchar(50) DEFAULT NULL,
  `Mobile` varchar(50) DEFAULT NULL,
  `Fax` varchar(50) DEFAULT NULL,
  `Email` varchar(255) DEFAULT NULL,
  `Roles` varchar(255) DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=InnoDB;

#
# Table structure for table `t_risktypes`
#

DROP TABLE IF EXISTS `t_risktypes`;
CREATE TABLE `t_risktypes` (
  `Risk` varchar(12) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '0',
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Risk`),
  INDEX `ix_risktypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_roleconstraint`
#

DROP TABLE IF EXISTS `t_roleconstraint`;
CREATE TABLE `t_roleconstraint` (
  `ConnectorID` int(11) NOT NULL DEFAULT '0',
  `Constraint` varchar(255) NOT NULL,
  `ConnectorEnd` varchar(50) NOT NULL,
  `ConstraintType` varchar(12) NOT NULL,
  `Notes` text,
  PRIMARY KEY (`ConnectorID`,`Constraint`,`ConnectorEnd`,`ConstraintType`),
  INDEX `ix_roleconstraint_Constraint` (`Constraint`),
  INDEX `ix_roleconstraint_ConnectorID` (`ConnectorID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_rtf`
#

DROP TABLE IF EXISTS `t_rtf`;
CREATE TABLE `t_rtf` (
  `Type` varchar(50) DEFAULT NULL,
  `Template` text
) ENGINE=InnoDB;

#
# Table structure for table `t_rtfreport`
#

DROP TABLE IF EXISTS `t_rtfreport`;
CREATE TABLE `t_rtfreport` (
  `TemplateID` varchar(200) NOT NULL,
  `RootPackage` int(11) DEFAULT '0',
  `Filename` varchar(255) DEFAULT NULL,
  `Details` int(3) DEFAULT NULL,
  `ProcessChildren` int(3) DEFAULT NULL,
  `ShowDiagrams` int(3) DEFAULT NULL,
  `Heading` varchar(255) DEFAULT NULL,
  `Requirements` int(3) DEFAULT NULL,
  `Associations` int(3) DEFAULT NULL,
  `Scenarios` int(3) DEFAULT NULL,
  `ChildDiagrams` int(3) DEFAULT NULL,
  `Attributes` int(3) DEFAULT NULL,
  `Methods` int(3) DEFAULT NULL,
  `ImageType` int(11) DEFAULT '0',
  `Paging` int(3) DEFAULT NULL,
  `Intro` text,
  `Resources` int(3) DEFAULT NULL,
  `Constraints` int(3) DEFAULT NULL,
  `Tagged` int(3) DEFAULT NULL,
  `ShowTag` int(3) DEFAULT NULL,
  `ShowAlias` int(3) DEFAULT NULL,
  `PDATA1` varchar(255) DEFAULT NULL,
  `PDATA2` varchar(255) DEFAULT NULL,
  `PDATA3` varchar(255) DEFAULT NULL,
  `PDATA4` text,
  PRIMARY KEY (`TemplateID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_rules`
#

DROP TABLE IF EXISTS `t_rules`;
CREATE TABLE `t_rules` (
  `RuleID` varchar(50) NOT NULL,
  `RuleName` varchar(255) NOT NULL,
  `RuleType` varchar(255) NOT NULL,
  `RuleActive` int(11) NOT NULL DEFAULT '0',
  `ErrorMsg` varchar(255) DEFAULT NULL,
  `Flags` varchar(255) DEFAULT NULL,
  `RuleOCL` text,
  `RuleXML` text,
  `Notes` text,
  PRIMARY KEY (`RuleID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_scenariotypes`
#

DROP TABLE IF EXISTS `t_scenariotypes`;
CREATE TABLE `t_scenariotypes` (
  `ScenarioType` varchar(12) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '1',
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ScenarioType`),
  INDEX `ix_scenariotypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_script`
#

DROP TABLE IF EXISTS `t_script`;
CREATE TABLE `t_script` (
  `ScriptID` int(11) NOT NULL AUTO_INCREMENT,
  `ScriptCategory` varchar(100) DEFAULT NULL,
  `ScriptName` varchar(150) DEFAULT NULL,
  `ScriptAuthor` varchar(255) DEFAULT NULL,
  `Notes` text,
  `Script` text,
  PRIMARY KEY (`ScriptID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_secgroup`
#

DROP TABLE IF EXISTS `t_secgroup`;
CREATE TABLE `t_secgroup` (
  `GroupID` varchar(40) NOT NULL,
  `GroupName` varchar(32) NOT NULL,
  `Description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`GroupID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_secgrouppermission`
#

DROP TABLE IF EXISTS `t_secgrouppermission`;
CREATE TABLE `t_secgrouppermission` (
  `GroupID` varchar(40) NOT NULL,
  `PermissionID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`GroupID`,`PermissionID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_seclocks`
#

DROP TABLE IF EXISTS `t_seclocks`;
CREATE TABLE `t_seclocks` (
  `UserID` varchar(40) NOT NULL,
  `GroupID` varchar(40) DEFAULT NULL,
  `EntityType` varchar(32) NOT NULL,
  `EntityID` varchar(40) NOT NULL,
  `Timestamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `LockType` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`EntityID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_secpermission`
#

DROP TABLE IF EXISTS `t_secpermission`;
CREATE TABLE `t_secpermission` (
  `PermissionID` int(11) NOT NULL DEFAULT '0',
  `PermissionName` varchar(50) NOT NULL,
  PRIMARY KEY (`PermissionID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_secpolicies`
#

DROP TABLE IF EXISTS `t_secpolicies`;
CREATE TABLE `t_secpolicies` (
  `Property` varchar(100) NOT NULL,
  `Value` varchar(255) NOT NULL,
  PRIMARY KEY (`Property`)
) ENGINE=InnoDB;

#
# Table structure for table `t_secuser`
#

DROP TABLE IF EXISTS `t_secuser`;
CREATE TABLE `t_secuser` (
  `UserID` varchar(40) NOT NULL,
  `UserLogin` varchar(32) NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `Surname` varchar(50) NOT NULL,
  `Department` varchar(50) DEFAULT NULL,
  `Password` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`UserID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_secusergroup`
#

DROP TABLE IF EXISTS `t_secusergroup`;
CREATE TABLE `t_secusergroup` (
  `UserID` varchar(40) NOT NULL,
  `GroupID` varchar(40) NOT NULL,
  PRIMARY KEY (`UserID`,`GroupID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_secuserpermission`
#

DROP TABLE IF EXISTS `t_secuserpermission`;
CREATE TABLE `t_secuserpermission` (
  `UserID` varchar(40) NOT NULL,
  `PermissionID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`UserID`,`PermissionID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_snapshot`
#

DROP TABLE IF EXISTS `t_snapshot`;
CREATE TABLE `t_snapshot` (
  `SnapshotID` varchar(40) NOT NULL,
  `SeriesID` varchar(40) NOT NULL,
  `Position` int(11) NOT NULL DEFAULT '0',
  `SnapshotName` varchar(100) NOT NULL,
  `Notes` text,
  `Style` varchar(255) NOT NULL,
  `ElementID` varchar(40) DEFAULT NULL,
  `ElementType` varchar(50) NOT NULL,
  `StrContent` text,
  `BinContent1` longblob,
  `BinContent2` longblob,
  PRIMARY KEY (`SnapshotID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_statustypes`
#

DROP TABLE IF EXISTS `t_statustypes`;
CREATE TABLE `t_statustypes` (
  `Status` varchar(50) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Status`)
) ENGINE=InnoDB;

#
# Table structure for table `t_stereotypes`
#

DROP TABLE IF EXISTS `t_stereotypes`;
CREATE TABLE `t_stereotypes` (
  `Stereotype` varchar(255) NOT NULL,
  `AppliesTo` varchar(255) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `MFEnabled` int(11) DEFAULT NULL,
  `MFPath` varchar(255) DEFAULT NULL,
  `Metafile` longblob,
  `Style` text,
  `ea_guid` varchar(50) NOT NULL,
  `VisualType` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`AppliesTo`,`Stereotype`),
  INDEX `ix_stereotypes_Stereotype` (`Stereotype`)
) ENGINE=InnoDB;

#
# Table structure for table `t_taggedvalue`
#

DROP TABLE IF EXISTS `t_taggedvalue`;
CREATE TABLE `t_taggedvalue` (
  `PropertyID` varchar(40) NOT NULL,
  `ElementID` varchar(40) NOT NULL,
  `BaseClass` varchar(100) NOT NULL,
  `TagValue` text,
  `Notes` text,
  PRIMARY KEY (`PropertyID`),
  INDEX `ix_taggedvalue_ElementID` (`ElementID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_tasks`
#

DROP TABLE IF EXISTS `t_tasks`;
CREATE TABLE `t_tasks` (
  `TaskID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `TaskType` varchar(255) DEFAULT NULL,
  `NOTES` text,
  `Priority` varchar(255) DEFAULT NULL,
  `Status` varchar(255) DEFAULT NULL,
  `Owner` varchar(255) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `Phase` varchar(50) DEFAULT NULL,
  `History` text,
  `Percent` int(11) DEFAULT NULL,
  `TotalTime` int(11) DEFAULT NULL,
  `ActualTime` int(11) DEFAULT NULL,
  `AssignedTo` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`TaskID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_tcf`
#

DROP TABLE IF EXISTS `t_tcf`;
CREATE TABLE `t_tcf` (
  `TCFID` varchar(12) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `Weight` double NOT NULL DEFAULT '1',
  `Value` double DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`TCFID`),
  INDEX `ix_tcf_Weight` (`Weight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_template`
#

DROP TABLE IF EXISTS `t_template`;
CREATE TABLE `t_template` (
  `TemplateID` varchar(40) NOT NULL,
  `TemplateType` varchar(50) NOT NULL,
  `TemplateName` varchar(100) NOT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  `Style` varchar(255) DEFAULT NULL,
  `Template` text,
  PRIMARY KEY (`TemplateID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_testclass`
#

DROP TABLE IF EXISTS `t_testclass`;
CREATE TABLE `t_testclass` (
  `TestClass` varchar(50) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`TestClass`)
) ENGINE=InnoDB;

#
# Table structure for table `t_testplans`
#

DROP TABLE IF EXISTS `t_testplans`;
CREATE TABLE `t_testplans` (
  `PlanID` varchar(50) NOT NULL,
  `Category` varchar(100) NOT NULL,
  `Name` varchar(150) NOT NULL,
  `Author` varchar(255) DEFAULT NULL,
  `Notes` text,
  `TestPlan` text,
  PRIMARY KEY (`PlanID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_testtypes`
#

DROP TABLE IF EXISTS `t_testtypes`;
CREATE TABLE `t_testtypes` (
  `TestType` varchar(12) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '1',
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`TestType`),
  INDEX `ix_testtypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_trxtypes`
#

DROP TABLE IF EXISTS `t_trxtypes`;
CREATE TABLE `t_trxtypes` (
  `TRX` varchar(255) NOT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `NumericWeight` double NOT NULL DEFAULT '1',
  `Notes` text,
  `Style` text,
  `TRX_ID` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`TRX_ID`),
  INDEX `ix_trxtypes_NumericWeight` (`NumericWeight`)
) ENGINE=InnoDB;

#
# Table structure for table `t_umlpattern`
#

DROP TABLE IF EXISTS `t_umlpattern`;
CREATE TABLE `t_umlpattern` (
  `PatternID` int(4) NOT NULL AUTO_INCREMENT,
  `PatternCategory` varchar(100) DEFAULT NULL,
  `PatternName` varchar(150) NOT NULL,
  `Style` varchar(250) DEFAULT NULL,
  `Notes` text,
  `PatternXML` text NOT NULL,
  `Version` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`PatternID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_version`
#

DROP TABLE IF EXISTS `t_version`;
CREATE TABLE `t_version` (
  `ElementID` varchar(50) NOT NULL,
  `VersionID` varchar(255) NOT NULL,
  `ElementType` varchar(100) NOT NULL,
  `Flags` varchar(255) DEFAULT NULL,
  `ExternalFile` varchar(255) DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  `Owner` varchar(255) DEFAULT NULL,
  `VersionDate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Branch` varchar(255) DEFAULT NULL,
  `ElementXML` text,
  PRIMARY KEY (`ElementID`,`VersionID`),
  INDEX `ix_version_elementID` (`ElementID`)
) ENGINE=InnoDB;

#
# Table structure for table `t_xref`
#

DROP TABLE IF EXISTS `t_xref`;
CREATE TABLE `t_xref` (
  `XrefID` varchar(255) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Type` varchar(255) NOT NULL,
  `Visibility` varchar(255) DEFAULT NULL,
  `Namespace` varchar(255) DEFAULT NULL,
  `Requirement` varchar(255) DEFAULT NULL,
  `Constraint` varchar(255) DEFAULT NULL,
  `Behavior` varchar(255) DEFAULT NULL,
  `Partition` varchar(255) DEFAULT NULL,
  `Description` text,
  `Client` varchar(255) DEFAULT NULL,
  `Supplier` varchar(255) DEFAULT NULL,
  `Link` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`XrefID`),
  INDEX `ix_xref_Client` (`Client`),
  INDEX `ix_xref_Supplier` (`Supplier`),
  INDEX `ix_xref_Type` (`Type`),
  INDEX `ix_xref_Name` (`Name`)
) ENGINE=InnoDB;

#
# Table structure for table `t_xrefsystem`
#

DROP TABLE IF EXISTS `t_xrefsystem`;
CREATE TABLE `t_xrefsystem` (
  `XrefID` varchar(255) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Type` varchar(255) NOT NULL,
  `Visibility` varchar(255) DEFAULT NULL,
  `Namespace` varchar(255) DEFAULT NULL,
  `Requirement` varchar(255) DEFAULT NULL,
  `Constraint` varchar(255) DEFAULT NULL,
  `Behavior` varchar(255) DEFAULT NULL,
  `Partition` varchar(255) DEFAULT NULL,
  `Description` text,
  `Client` varchar(255) DEFAULT NULL,
  `Supplier` varchar(255) DEFAULT NULL,
  `Link` varchar(255) DEFAULT NULL,
  `ToolID` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`XrefID`),
  INDEX `ix_xrefsystem_Client` (`Client`),
  INDEX `ix_xrefsystem_Supplier` (`Supplier`),
  INDEX `ix_xrefsystem_Type` (`Type`)
) ENGINE=InnoDB;

#
# Table structure for table `t_xrefuser`
#

DROP TABLE IF EXISTS `t_xrefuser`;
CREATE TABLE `t_xrefuser` (
  `XrefID` varchar(255) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Type` varchar(255) NOT NULL,
  `Visibility` varchar(255) DEFAULT NULL,
  `Namespace` varchar(255) DEFAULT NULL,
  `Requirement` varchar(255) DEFAULT NULL,
  `Constraint` varchar(255) DEFAULT NULL,
  `Behavior` varchar(255) DEFAULT NULL,
  `Partition` varchar(255) DEFAULT NULL,
  `Description` text,
  `Client` varchar(255) DEFAULT NULL,
  `Supplier` varchar(255) DEFAULT NULL,
  `Link` varchar(255) DEFAULT NULL,
  `ToolID` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`XrefID`),
  INDEX `ix_refuser_Client` (`Client`),
  INDEX `ix_refuser_Supplier` (`Supplier`),
  INDEX `ix_refuser_Type` (`Type`)
) ENGINE=InnoDB;

#
# Table structure for table `usys_system`
#

DROP TABLE IF EXISTS `usys_system`;
CREATE TABLE `usys_system` (
  `Property` varchar(50) NOT NULL,
  `Value` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Property`)
) ENGINE=InnoDB;

#
# Table structure for table `usystables`
#

DROP TABLE IF EXISTS `usystables`;
CREATE TABLE `usystables` (
  `TableName` varchar(50) NOT NULL,
  `RelOrder` int(11) DEFAULT '0',
  `DisplayName` varchar(50) DEFAULT NULL,
  `FromVer` varchar(50) DEFAULT NULL,
  `ToVer` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`TableName`)
) ENGINE=InnoDB;

#
# Table structure for table `usysoldtables`
#

DROP TABLE IF EXISTS `usysoldtables`;
CREATE TABLE `usysoldtables` (
  `TableName` varchar(50) DEFAULT NULL,
  `NewName` varchar(50) DEFAULT NULL,
  `RelOrder` int(11) DEFAULT '0',
  `FixCode` int(11) DEFAULT NULL
) ENGINE=InnoDB;

#
# Table structure for table `usysqueries`
#

DROP TABLE IF EXISTS `usysqueries`;
CREATE TABLE `usysqueries` (
  `QueryName` varchar(50) DEFAULT NULL,
  `NewName` varchar(50) DEFAULT NULL,
  `FixCode` int(11) DEFAULT NULL
) ENGINE=InnoDB;

