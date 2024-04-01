-- 한 줄 주석 처리

/*
여러 줄 주석 처리
*/

-- case 1
USE classicmodels;
SELECT * FROM customers;

-- case 2
SELECT * FROM classicmodels.customers;

-- 현재 DB 확인
-- SELECT DATABASES();

SHOW TABLES;

DESC orders;

-- p.26
DESC customers;

SELECT 
	customerName
    , addressLine1
    , city
FROM customers;

-- 집계함수
-- COUNT, SUM, AVG 등
SELECT 
	SUM(AMOUNT)
    , COUNT(checknumber)
FROM payments;

DESC payments;

-- 모든 결과 조회 : * 사용,
-- 단, 실무에서는 이거 쓰면 사수한테 혼남
SELECT * FROM payments;
-- 서버자원 팀별로 공유하는데 1억개 데이터를 다 출력해버리면? 끔찍한 결말

-- 30p. AS
-- 컬럼명 변경 
SELECT 
	COUNT(productcode) AS N_PRODUCTS
FROM products;

-- 서브쿼리, 윈도우함수 절 기억하면 됩니다!!

-- DISTINCT 중복제거 
SELECT DISTINCT ordernumber
FROM orderdetails
ORDER BY ordernumber;

-- WHERE
SELECT *
FROM products
WHERE productline = 'Motorcycles';

-- WHERE, BETWEEN 연산자 
-- 요청사항 2010~2014년에 출시된 상품 번호 필요 
SELECT *
FROM orderdetails
WHERE priceeach BETWEEN 30 AND 50
;

-- WHERE 대소 관계 표현 
SELECT *
FROM orderdetails
WHERE priceeach >= 30
ORDER BY priceeach ASC;

-- WHERE : IN 꼭 기억하자!! 
#SELECT 컬럼명
#FROM 테이블명
#WHERE 컬럼명 IN(값1, 값2); -- OR 연산자 대체 
-- 서브쿼리 할 때도 매우 자주 사용함

SELECT *
FROM orderdetails
WHERE ordernumber IN (10184,10104,10124);

SELECT * 
FROM orderdetails
WHERE ordernumber = 10184 OR ordernumber = 10104 OR ordernumber = 10124;

-- 테이블명 : customers
-- country 가 USA 또는 Canada 인 모든 데이터 조회
DESC customers;

SELECT *
FROM customers
WHERE country NOT IN ('USA','Canada');

-- IS NULL 연산자 / IS NOT NULL 연산자
-- 대표적인 블로깅 주제
SELECT *
FROM employees
WHERE reportsTo IS NULL;

SELECT *
FROM employees
WHERE reportsTo IS NOT NULL;

SELECT *
FROM employees;

-- MySQL 설치
-- DB에 데이터 입력
-- 간단한 SQL 구문 / (SELECT FROM WHERE 일부)

-- 내일 수업 
-- 기본쿼리 수업 & 테이블 생성, 추가, 삭제, 수정
-- 4장 분석관련 쿼리 작성 


