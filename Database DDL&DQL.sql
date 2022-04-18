--
-- DDL(adapted from: jordan code)
--

-- create the student table, this is the data to demo

CREATE TABLE `student` (
  `studen_id` mediumint(8) unsigned NOT NULL auto_increment,
  `stu_name` varchar(50) default NULL,
  `stu_gender` varchar(50) default NULL,
  `stu_university` varchar(50) default NULL,
  `stu_course` varchar(50) default NULL,  
  `stu_email` varchar(50) default NULL,
  `stu_phone` varchar(50) default NULL,
  `stu_address` varchar(50) default NULL,  
  `stu_postcode` varchar(50) default NULL,    
  PRIMARY KEY (`studen_id`)
) AUTO_INCREMENT=1;

INSERT INTO `student` (`stu_name`,`stu_gender`,`stu_university`,`stu_course`,`stu_email`,`stu_phone`,`stu_address`,`stu_postcode`) VALUES 
("James","male","warwick","ebm","James@warwaick.ac.uk","12345678","Coventry","CV4 7AL"),("Emily","female","Cambridge","Maths","Emily@cambridge.ac.uk","23456781","Cambridge","CA2 6ES")


-- SQL Query

--Example 1 - show students from Warwick (Analyse student sources)
--SELECT * FROM student WHERE `stu_university` LIKE `warwick%`;

--Example 2 - show student list are there in project 1,6 & 17 (Check the students list in specific project)
--SELECT * FROM student WHERE `project_id` IN (1,6,17);

--Example 3 - show student list James has supervised order by student id (Allow supervisor to look up students that they need to contact with)
--SELECT * FROM `supervisor` WHERE `sup_name` LIKE `James%` OR `%James` ORDER BY `student_id`

--Example 4 - Count how many supervisors are there in 2021 (Analyse whether the number of supervisors is enough)
--SELECT * COUNT(`supervisor_id`) FROM supervisor WHERE `sup_year` = 2021

--Example 5 - Count how many students choose project 1,3,5 (Analysse which project is the most popular)
--SELECT * COUNT(`student_id`) FROM project WHERE `project_id` IN (1,3,5)

--Example 6 - Join student and project tables (To show what project the student select and its detail)
--Select `student_id`, `stu_name`, `stu_course`, `stu_university` FROM student 
--RIGHT JOIN project ON student.student_id = project.student_id