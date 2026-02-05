/*
Question: What skills are required for the top-paying Data Analyst roles?
- Use the top 10 highest paying Data Analyst jobs from first query
- Add the specific skills required for those roles
- Why? It provides an insight of skills required by these top paying jobs
*/

WITH top_paying_jobs AS (
    SELECT
        job_postings_fact.job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_location = 'Anywhere' AND
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

SELECT
    top_paying_jobs.*,
    skills
FROM
    top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id

/*
Key Insights
1. SQL + Python dominate
Both appear in 44% of these top-paying roles ($192K–$445K). At this salary level, they're foundational.
2. Excel persists at high salaries
Siemens ($385K) and Smartcat ($192K) both require Excel — it's not just for entry-level.
3. Cloud/infrastructure skills unlock $300K+
Netflix ($445K) needs SQL + Python. Confluent ($297K) needs Kubernetes. Engineering-adjacent skills push salaries higher.
4. BI tools (Tableau, Looker) are rare
Only Edge & Node lists them. At these levels, employers want code, not dashboards.
5. Specialized tools appear once each
SAP, MATLAB, Oracle, GraphQL — niche skills tied to specific company needs.

[
  {
    "job_id": 448257,
    "job_title": "Analytics Engineer (L5) - Live Quality of Experience",
    "salary_year_avg": "445000.0",
    "company_name": "Netflix",
    "skills": "sql"
  },
  {
    "job_id": 448257,
    "job_title": "Analytics Engineer (L5) - Live Quality of Experience",
    "salary_year_avg": "445000.0",
    "company_name": "Netflix",
    "skills": "python"
  },
  {
    "job_id": 217345,
    "job_title": "Financial & Data Analyst - Pricing (12 months Contract)",
    "salary_year_avg": "385000.0",
    "company_name": "Siemens",
    "skills": "excel"
  },
  {
    "job_id": 217345,
    "job_title": "Financial & Data Analyst - Pricing (12 months Contract)",
    "salary_year_avg": "385000.0",
    "company_name": "Siemens",
    "skills": "sap"
  },
  {
    "job_id": 420010,
    "job_title": "Director of Engineering - Analytics",
    "salary_year_avg": "296910.0",
    "company_name": "Confluent",
    "skills": "kubernetes"
  },
  {
    "job_id": 465683,
    "job_title": "Data Analyst",
    "salary_year_avg": "264000.0",
    "company_name": "Edge & Node",
    "skills": "sql"
  },
  {
    "job_id": 465683,
    "job_title": "Data Analyst",
    "salary_year_avg": "264000.0",
    "company_name": "Edge & Node",
    "skills": "go"
  },
  {
    "job_id": 465683,
    "job_title": "Data Analyst",
    "salary_year_avg": "264000.0",
    "company_name": "Edge & Node",
    "skills": "graphql"
  },
  {
    "job_id": 465683,
    "job_title": "Data Analyst",
    "salary_year_avg": "264000.0",
    "company_name": "Edge & Node",
    "skills": "node"
  },
  {
    "job_id": 465683,
    "job_title": "Data Analyst",
    "salary_year_avg": "264000.0",
    "company_name": "Edge & Node",
    "skills": "tableau"
  },
  {
    "job_id": 465683,
    "job_title": "Data Analyst",
    "salary_year_avg": "264000.0",
    "company_name": "Edge & Node",
    "skills": "looker"
  },
  {
    "job_id": 465683,
    "job_title": "Data Analyst",
    "salary_year_avg": "264000.0",
    "company_name": "Edge & Node",
    "skills": "git"
  },
  {
    "job_id": 452509,
    "job_title": "AI Deep Learning Quantitative Analyst (Remote)",
    "salary_year_avg": "230000.0",
    "company_name": "Nurp",
    "skills": "python"
  },
  {
    "job_id": 452509,
    "job_title": "AI Deep Learning Quantitative Analyst (Remote)",
    "salary_year_avg": "230000.0",
    "company_name": "Nurp",
    "skills": "r"
  },
  {
    "job_id": 452509,
    "job_title": "AI Deep Learning Quantitative Analyst (Remote)",
    "salary_year_avg": "230000.0",
    "company_name": "Nurp",
    "skills": "matlab"
  },
  {
    "job_id": 452509,
    "job_title": "AI Deep Learning Quantitative Analyst (Remote)",
    "salary_year_avg": "230000.0",
    "company_name": "Nurp",
    "skills": "aws"
  },
  {
    "job_id": 122889,
    "job_title": "Product Data Analyst",
    "salary_year_avg": "226500.0",
    "company_name": "Get It Recruit - Information Technology",
    "skills": "sql"
  },
  {
    "job_id": 122889,
    "job_title": "Product Data Analyst",
    "salary_year_avg": "226500.0",
    "company_name": "Get It Recruit - Information Technology",
    "skills": "python"
  },
  {
    "job_id": 122889,
    "job_title": "Product Data Analyst",
    "salary_year_avg": "226500.0",
    "company_name": "Get It Recruit - Information Technology",
    "skills": "databricks"
  },
  {
    "job_id": 122889,
    "job_title": "Product Data Analyst",
    "salary_year_avg": "226500.0",
    "company_name": "Get It Recruit - Information Technology",
    "skills": "spark"
  },
  {
    "job_id": 229343,
    "job_title": "Head of FP&A, Data & Analytics",
    "salary_year_avg": "224000.0",
    "company_name": "Atlassian",
    "skills": "sql"
  },
  {
    "job_id": 229343,
    "job_title": "Head of FP&A, Data & Analytics",
    "salary_year_avg": "224000.0",
    "company_name": "Atlassian",
    "skills": "python"
  },
  {
    "job_id": 229343,
    "job_title": "Head of FP&A, Data & Analytics",
    "salary_year_avg": "224000.0",
    "company_name": "Atlassian",
    "skills": "r"
  },
  {
    "job_id": 229343,
    "job_title": "Head of FP&A, Data & Analytics",
    "salary_year_avg": "224000.0",
    "company_name": "Atlassian",
    "skills": "c"
  },
  {
    "job_id": 229343,
    "job_title": "Head of FP&A, Data & Analytics",
    "salary_year_avg": "224000.0",
    "company_name": "Atlassian",
    "skills": "oracle"
  },
  {
    "job_id": 229343,
    "job_title": "Head of FP&A, Data & Analytics",
    "salary_year_avg": "224000.0",
    "company_name": "Atlassian",
    "skills": "atlassian"
  },
  {
    "job_id": 96272,
    "job_title": "Medical Analytics",
    "salary_year_avg": "198500.0",
    "company_name": "Pfizer",
    "skills": "gcp"
  },
  {
    "job_id": 458616,
    "job_title": "Data Analyst (HR & Finance)",
    "salary_year_avg": "192000.0",
    "company_name": "Smartcat",
    "skills": "c"
  },
  {
    "job_id": 458616,
    "job_title": "Data Analyst (HR & Finance)",
    "salary_year_avg": "192000.0",
    "company_name": "Smartcat",
    "skills": "excel"
  },
  {
    "job_id": 458616,
    "job_title": "Data Analyst (HR & Finance)",
    "salary_year_avg": "192000.0",
    "company_name": "Smartcat",
    "skills": "sheets"
  }
]
*/