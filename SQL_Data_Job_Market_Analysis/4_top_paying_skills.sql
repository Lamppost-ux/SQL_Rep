/*
Question: What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst roles
*/
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND
    job_work_from_home = TRUE
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;

/*
Key Trends
1. Common skills (SQL, Python, Excel) are absent
They're not here because everyone has them — high supply = average salary gets diluted. The top payers are niche skills with fewer qualified candidates.
2. Engineering-adjacent skills dominate
SkillAvg SalaryCategoryKubernetes$147KDevOps/InfrastructureKafka$146KData StreamingSpark$130KBig DataHadoop$129KBig DataTerraform$125KInfrastructure
Data Analysts who can touch engineering systems get paid more.
3. API/Backend skills pay premium
GraphQL ($264K) and Node ($171K) at the top suggest analysts who understand backend systems or can build data APIs are rare and valued.
4. Legacy skills still pay well
Perl ($158K), C ($134K), Unix ($118K), Shell ($130K) — old systems still run businesses. Few young analysts learn these.
5. Enterprise tools command high salaries
SAP ($143K), Atlassian ($182K) — companies using enterprise software pay for analysts who understand their stack.

*/