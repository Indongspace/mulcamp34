USE instacart;

SELECT * FROM aisles;
SELECT * FROM departments;
SELECT * FROM order_products__prior;
SELECT * FROM orders;
SELECT * FROM products;

-- 지표추출
-- (1) 전체 주문건수
-- 테이블 : orders 
SELECT COUNT(*) FROM orders;
DESC orders;

SELECT COUNT(DISTINCT order_id) FROM orders;

-- (2) 전체 구매자 수
SELECT COUNT(user_id), COUNT(DISTINCT user_id) FROM orders;

-- (3) 상품별 주문 건수
-- 힌트 : order_products__prior, products 
SELECT
	B.product_name 
    , COUNT(DISTINCT A.order_id) F
FROM order_products__prior A 
LEFT JOIN products B 
ON A.product_id = B.product_id 
GROUP BY 1
ORDER BY 2 DESC
;

-- 장바구니에 가장 먼저 넣는 상품 10개 
SELECT 
	product_id
    , SUM(CASE WHEN ADD_TO_CART_ORDER = 1 THEN 1 ELSE 0 END) F_1ST 
FROM order_products__prior
GROUP BY 1
;

-- 순위 뽑고, 상위 10순위 정하면 끝! 
SELECT *
FROM (
	SELECT 
		product_id
		, SUM(CASE WHEN ADD_TO_CART_ORDER = 1 THEN 1 ELSE 0 END) F_1ST 
	FROM order_products__prior
	GROUP BY 1
) A
;

SELECT * FROM orders 
ORDER BY order_number DESC
LIMIT 5;

SELECT 
	product_id
    , SUM(CASE WHEN ADD_TO_CART_ORDER = 1 THEN 1 ELSE 0 END) F_1ST 
FROM order_products__prior
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;

-- 시간별 주문건수 
SELECT * FROM orders;

SELECT 
	order_hour_of_day
    , COUNT(DISTINCT order_id) F
FROM orders
GROUP BY 1
ORDER BY 1
;

-- 첫 구매 후 다음구매까지 걸린 평균 일 수 
SELECT 
	AVG(days_since_prior_order) 
FROM orders
WHERE order_number = 2 -- 이전 주문이 이루어진 며칠 뒤에 구매를 했느냐!!
;

-- 주문 건 당 평균 구매 상품 수(UPT, Unit Per Transaction)
SELECT COUNT(product_id) / COUNT(DISTINCT order_id) UPT
FROM order_products__prior
;

-- 인당 평균 주문 건 수
SELECT COUNT(DISTINCT order_id) / COUNT(DISTINCT user_id) AVG_F
FROM orders;

-- 재구매율이 가장 높은 상품 10개 
-- 테이블 : order_products_prior 
-- 상품별 재구매율 계산
SELECT 
	product_id
    , SUM(CASE WHEN REORDERED = 1 THEN 1 ELSE 0 END) / COUNT(*) RET_RATIO
FROM 
	order_products__prior
GROUP BY 1
;
-- 재구매율로 랭크(순위) 열 생성
SELECT 
	* 
    , ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) RNK
FROM (
	SELECT 
		product_id
		, SUM(CASE WHEN REORDERED = 1 THEN 1 ELSE 0 END) / COUNT(*) RET_RATIO
	FROM 
		order_products__prior
	GROUP BY 1
) BASE
;

-- Top10(재구매율) 상품 추출
SELECT * 
FROM (
	SELECT 
		* 
		, ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) RNK
	FROM (
		SELECT 
			product_id
			, SUM(CASE WHEN REORDERED = 1 THEN 1 ELSE 0 END) / COUNT(*) RET_RATIO
		FROM 
			order_products__prior
		GROUP BY 1
	) BASE
) BASE 
WHERE RNK BETWEEN 1 AND 10
;

-- Department별 재구매율이 가장 높은 상품 10개
SELECT 
	C.department
    , A.product_id
    , SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) / COUNT(*) RET_RATIO
FROM order_products__prior A
LEFT JOIN products B
ON A.product_id = B.product_id
LEFT JOIN departments C 
ON B.department_id = C.department_id
GROUP BY 1, 2
;

-- 순위 구하기
SELECT 
	*
    , ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) RNK
FROM (
	SELECT 
		C.department
		, A.product_id
		, SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) / COUNT(*) RET_RATIO
	FROM order_products__prior A
	LEFT JOIN products B
	ON A.product_id = B.product_id
	LEFT JOIN departments C 
	ON B.department_id = C.department_id
	GROUP BY 1, 2
) BASE
;

-- 순위 10개 구하기
SELECT * 
FROM (
	SELECT 
		*
		, ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) RNK
	FROM (
		SELECT 
			C.department
			, A.product_id
			, SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) / COUNT(*) RET_RATIO
		FROM order_products__prior A
		LEFT JOIN products B
		ON A.product_id = B.product_id
		LEFT JOIN departments C 
		ON B.department_id = C.department_id
		GROUP BY 1, 2
	) BASE
) BASE
WHERE RET_RATIO < 1
;

-- 구매자 분석 
-- 10분위 분석 
SELECT COUNT(DISTINCT USER_ID)
FROM (
	SELECT
		USER_ID
        , COUNT(DISTINCT ORDER_ID) F 
	FROM orders
    GROUP BY 1
) A
;

CREATE TEMPORARY TABLE INSTACART.USER_QUANTILE AS
SELECT *,
CASE WHEN RNK <= 316 THEN 'Quantile_1'
WHEN RNK <= 632 THEN 'Quantile_2'
WHEN RNK <= 948 THEN 'Quantile_3'
WHEN RNK <= 1264 THEN 'Quantile_4'
WHEN RNK <= 1580 THEN 'Quantile_5'
WHEN RNK <= 1895 THEN 'Quantile_6'
WHEN RNK <= 2211 THEN 'Quantile_7'
WHEN RNK <= 2527 THEN 'Quantile_8'
WHEN RNK <= 2843 THEN 'Quantile_9'
WHEN RNK <= 3159 THEN 'Quantile_10' END quantile
FROM
(SELECT *,
ROW_NUMBER() OVER(ORDER BY F DESC) RNK
FROM
(SELECT USER_ID,
COUNT(DISTINCT ORDER_ID) F
FROM INSTACART.ORDERS
GROUP
BY 1) A) A
;

SELECT
	quantile
    , SUM(F) F 
FROM user_quantile 
GROUP BY 1;

SELECT
	QUANTILE
    , SUM(F) / 3220 F
FROM user_quantile 
GROUP BY 1
;

-- 상품별 주문 건수와 재구매 비율 
SELECT 
	A.product_id
    , B.product_name
    , SUM(reordered) / SUM(1) reorder_rate
    , COUNT(DISTINCT order_id) F
FROM order_products__prior A
LEFT JOIN products B
ON A.product_id = B.product_id 
GROUP BY 1, 2
HAVING COUNT(DISTINCT order_id) > 10
;

-- 최근 DBMS 경향 
-- 점점 분석도구로 활용을 하려고 함 
-- 과거 : DB저장용
-- 최근 : DBMS를 활용해서 머신러닝 사용할 수 있음 (통계 분석 도구로 발전하고 있음)


