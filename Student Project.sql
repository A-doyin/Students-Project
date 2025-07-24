Create database Student_Project;
Use Student_Project;

select * from `sql_project_student_performance_classes`;
Select * from `sql_project_student_performance_scores`;
select * from `sql_project_student_performance_students`;
select * from `sql_project_student_performance_subjects`;
select * from  `sql_project_student_performance_terms`;

Alter table `sql_project_student_performance_classes` rename Students_classes;
Alter table `sql_project_student_performance_scores` rename Students_scores;
Alter table `sql_project_student_performance_students` rename Students_info;
Alter table `sql_project_student_performance_subjects` rename Students_subjects;
Alter table `sql_project_student_performance_terms` rename Student_terms;

-- Question 1-- 
-- List all students with their classes
select student_id, Full_name, class_name from students_info 
join students_classes using (class_id);

-- 2.	Find the number of male and female students.
select gender, count(*) from students_info group by gender ;


-- 3.	Show all subjects offered in the school.
select * from students_subjects;

-- 4.	List scores of a student named ‘Grace Obi’.
select score, full_name from students_info join students_scores on class_id where full_name = 'Grace Obi';
 
 -- 4b List scores of a student named 'Dana Olsen'
 select s.full_name, sb.subject_name, t.term_name, sc.score
 from students_scores sc
 join students_info s using (student_id)
 join students_subjects sb using (subject_id)
 join student_terms t using (term_id)
 where s.full_name = 'Dana Olsen' order by term_name;
 
--  5.	Find the average score per subject.
select subject_name, avg(score) as AVG_Score from students_scores
 join students_subjects using (subject_id)
 group by subject_name;

-- 6.	Find the highest and lowest scores per subject.
select subject_name, max(score) as Highest_Score, min(score) as Lowest_Score
from students_scores join students_subjects using (subject_id) 
group by subject_name ;


-- 7.	List top 3 students per subject. (based on total scores)
select * from (select full_name, subject_name, sum(score) as Total_score,
dense_rank() over (partition by subject_name order by sum(score) desc) as Top_3
from students_scores 
join students_info using(student_id)
join students_subjects using (subject_id)
group by full_name, subject_name)
ranked_scores 
where top_3 <=3;



-- 8.	Rank students in a class based on average score.
select * from (select s.full_name, c.class_name, round(avg(sc.score),2)as Avg_Score,
rank() over (partition by c.class_name order by Avg(sc.score) desc) as ranks
 from  students_scores sc 
 join students_info s on sc.student_id = s.student_id
 join students_classes c on s.class_id = c.class_id
 group by s.full_name, c.class_name) as Ranked_students;
 
 

-- 9.	Find students who failed any subject (score < 50).
select distinct  full_name, subject_name, score, term_name from students_scores
join students_info using (student_id)
join students_subjects using (subject_id) 
join student_terms using (term_id)
where score <50 order by full_name; 

select * from  students_subjects;
select* from students_classes;
select * from students_scores;
select * from students_info;
select * from student_terms;


-- 10.	Show the number of students per class.
select class_name, count(full_name) from students_classes
join students_info using (class_id) group by class_name order by class_name;

select class_name, count(student_id) as Student_count
from students_info join students_classes using (class_id)
group by class_name order by class_name;


-- 11.	Create a view to show student performance by term-- 
Create view Student_Term_Scores as 
select s.full_name, t.term_name, Avg(sc.score) as Avg_Score 
from students_scores sc 
join students_info s using (student_id)
join  student_terms t using (term_id)
group by s.full_name, t.term_name;
select * from Student_Term_Scores ;

-- 12.	Write a subquery to find students who improved across terms.
select * from students_scores, Students_info, Student_terms;
select first_term.full_name, first_term.avg_score as First_Term_Score, third_term.avg_score as Third_Term_Score
from
(select s.full_name, round(avg(sc.score),2) as Avg_Score from students_scores sc
join students_info s using (student_id)
where sc.term_id = 1
group by s.full_name) as First_Term

Join ( select s.full_name, round(avg(sc.score),2) as Avg_score from students_scores sc
join students_info s using (student_id)
where sc.term_id = 3
group by s.full_name) as Third_term
On first_term.full_name = third_term.full_name
where Third_term.avg_score > first_term.avg_score 
order by Third_term_score desc;

-- 13.	Use CASE to grade students: A (≥ 70), B (60-69), C (50-59), F (< 50)
select full_name, subject_name, score, term_name,
Case 
When score >= 70 Then 'A'
When score >= 60 Then 'B'
When score >= 50 Then 'C'
Else 'F'
End as Grade
from students_scores
join students_info using (student_id)
join students_subjects using (subject_id)
join student_terms using (term_id);

-- 14.	Show each student’s best-performing subject 
Select * from ( select full_name, subject_name, Term_name, round(avg(score),2) as Avg_score,
Rank () over (partition by full_name order by AVG(score) desc) as Ranks
 from students_scores join students_info using (student_id)
 join students_subjects using (subject_id)
 join student_terms using (term_id)
 group by full_name, subject_name, term_name) Ranked_subjects
 where ranks = 1;


-- 15.	Generate a report showing student names, class, subject, term, score, and grade
Select full_name, subject_name, term_name, score, class_name,
Case 
when sc.score >= 70 Then 'A'
When sc.score >= 60 Then 'B'
When sc.score >= 50 Then 'C'
When sc.score >= 40 Then 'D'
ELse 'F'
End as Grade
from Students_scores sc 
join students_info using (student_id)
join students_subjects using (subject_id)
join student_terms using (term_id)
join students_classes using (class_id);