-- HEALTHCARE ANALYSIS
 
-- Creating a Database for the project
create database healthcare_db;

use healthcare_db;

-- Importing the dataset
	-- Import data Wizard

-- PATIENT DEMOGRAPHIC
-- Age, Gender, City, Race
select * from patients;

-- Age Distribution
with t1 as 
	(select age,
	case
		when age <=25 then '18-25'
		when age <=35 then '26-35'
		when age <=45 then '36-45'
		when age <=55 then '46-55'
		when age <=65 then '56-65'
		when age <=75 then '66-75'
		else '>75'
	end as age_bracket
	from patients)
select age_bracket, count(*) as patientCount from t1
group by age_bracket
order by patientCount desc;


-- Gender Distribution
select gender, 
	count(gender) as genderCount,
	count(gender) * 100 / (select count(*) from patients) as genderPercentage
from patients
group by gender
order by genderPercentage desc;

-- Distribution of patients in each city
select `city id`, count(*) as patientCount from patients
group by `city id`
order by patientCount desc
limit 5;

-- joining city table
select * from cities;

select p.`city id`, state, city, count(`patient id`) as patientCount from patients p
inner join cities c
on p.`city id` = c.`city id`
group by `city id`, state, city
order by patientCount desc
limit 5;

-- Distirbution of Patients by Race
select race, 
	count(race) as raceCount,
	count(race) * 100 / (select count(*) from patients) as racePercentage
from patients
group by race
order by racePercentage desc;


-- Patient visit frequency --> Average patients per visits
select * from patients;
select `Patient ID`, count(*) from visits
group by `Patient ID`;

-- Returning Patients
with cte as 
	(select `Patient ID` as patients, count(*) as patientCount from visits
	group by `Patient ID`)
select patients, patientCount from cte
where patientCount > 1;

-- checking for patient name
with t1 as 
	(select v.`Patient ID` as id, `patient name` as patients, count(*) as patientCount 
    from patients p
    join visits v 
    on v.`patient id` = p.`patient id`
	group by id, patients),
t2 as 
	(select `Patient ID` as id2, race from patients)
select id, patients, race, patientCount from t1
join t2 on t1.id = t2.id2
where patientCount > 1;


-- DIAGNOSIS & TREATMENT
-- Top diagnosis: Most common diagnosis --> diagnosis distribution
select * from diagnoses;
select * from visits;

select v.`Diagnosis ID` as id, d.diagnosis as diagnosis_name, count(*) as commonDiagnosis
from visits v
join diagnoses d
on v.`Diagnosis ID` = d.`Diagnosis ID`
group by id, diagnosis_name
order by commonDiagnosis desc;

-- Procedure Utilization: Most common procedure --> procedure distribution
select * from procedures;
select * from visits;

select v.`Procedure ID` as id, d.`procedure` as procedure_name, count(*) as commonProcedures
from visits v
join procedures d
on v.`Procedure ID` = d.`Procedure ID`
group by id, procedure_name
order by commonProcedures desc;

-- Diagnosis-Procedure correlation: which procedure and diagnosis are performed for each diagnosis
select * from diagnoses;
select * from procedures;
select * from visits;

select `diagnosis`, `procedure`,
	count(*) as totalPatients
from visits v
join diagnoses d on v.`Diagnosis ID` = d.`Diagnosis ID`
join procedures p on v.`Procedure ID` = p.`Procedure ID`
group by `diagnosis`, `procedure`
order by totalPatients desc;


-- INSURANCE & BILLING
-- Which insurance providers covers the most patients
select * from visits;
select * from insurance;

select `insurance provider`, count(`patient id`) as totalPatient
from visits v
join insurance i 
on v.`insurance id` = i.`insurance id`
group by `insurance provider`
order by totalPatient desc;

-- Average Billing Amount
select * from visits;

-- Converting the date column to proper date column
select str_to_date(`Date of Visit`, '%m/%d/%Y') from visits;

update visits
set `Date of Visit` = (select str_to_date(`Date of Visit`, '%m/%d/%Y'));

alter table visits
modify `Date of Visit` date;


-- Follow up visits date
select str_to_date(`Follow-Up Visit Date`, '%d/%m/%Y') from visits;

update visits
set `Follow-Up Visit Date` = (select str_to_date(`Follow-Up Visit Date`, '%m/%d/%Y'));

alter table visits
modify `Follow-Up Visit Date` date;


select datediff(`Date of Visit`, `Follow-Up Visit Date`) as visits;


with t1 as 
	(select
		sum(`medication cost`) as medCost,
		sum(`treatment cost`) as treatCost,
		sum(`room charges(daily rate)`) as chargesCost,
		round(sum(`insurance coverage`),1) as insureCost
	from visits)
select ((medCost + treatCost + ChargesCost) - insureCost) as total_billing from t1;


/*
create temporary table billing_table
	(select `treatment cost`, 
			`medication cost`, 
            `insurance coverage`, 
            `room charges(daily rate)`,
            case when (`insurance coverage` * `room charges(daily rate)`) = 0 then `insurance coverage`
            else (`insurance coverage` * `room charges(daily rate)`) end as totalCharges
	from visits);
*/



-- PROVIDER & DEPARTMENT ANALYSIS
select *  from providers;
select * from departments;
select * from visits;

select `provider name` as doctors, gender, department, count(`patient id`) as patientCount
from visits v
join providers p 
on v.`provider id` = p.`provider id`
join departments d
on v.`department id` = d.`department id`
group by doctors, gender, department
order by patientCount desc;






