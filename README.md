##                                                 STRATEGIC INSIGHTS: DIGITAL ANALYTICS FOR E-COMMERCE STAKEHOLDERS


#### CLIENT​:
Our client is a newly launched direct-to-consumer e-commerce startup specializing in high-quality, adorable stuffed animal toys. ​
As a new player in the online retail space, the company is in a critical growth phase, aiming to establish its brand, understand its customer base, and drive sustainable sales performance.

#### COMPANY AIM:
- Refine marketing to prioritize high-converting traffic sources.
- Leverage website insights to enhance user experience and conversion rates.
- Expand market presence via efficient marketing and operational strategies.
- Establish a strong market position by prioritizing customer satisfaction and sustainable growth.
- Enhance product performance, streamline operations and position the company as a scalable e-commerce leader.

#### DATA AVAILABILITY:

| Dataset Name          | No of Rows | No of Columns | Primary Key        | Foreign Key                               | Granularity              |
|-----------------------|------------|---------------|--------------------|-------------------------------------------|--------------------------|
| Orders                | 32,313     | 08            | order_id           | Website_session_id, Product_ID            | Order Level              |
| Order_Items           | 40,025     | 07            | order_item_id      | order_id, Product_ID                      | Order Item Level         |
| Order_Items_Refunds   | 1,731      | 05            | Order_Item_        | Refund_ID, order_item_id, order_id        | Order Item Refunds       |
| Website_Sessions      | 4,72,871   | 09            | Website_session_id | -                                         | Website Sessions Level   |
| Website_PageViews     | 11,88,124  | 04            | Website_pageview_id| Website_session_id                        | Website Page Views Level |
| Products              | 4          | 03            | Product_ID         | -                                         | Product Level            |


#### ENTITY RELATIONSHIP MANAGEMENT:

| Tables Relationship                    | Type           |
|----------------------------------------|----------------|
| website_sessions → website_pageviews   | One-to-Many    |
| website_sessions → orders              | One-to-Many    |
| orders → order_items                   | One-to-Many    |
| products → order_items                 | One-to-Many    |
| orders → products                      | Many-to-Many   |
| order_items → order_item_refunds       | One-to-One     |


#### PROJECT OUTCOMES:
- The company secures funding with a strong, data-backed business case.​
- Investors gain clear visibility into business traction and scalability.​
- Stakeholders make informed decisions using structured analytics.​
- Improved customer insights drive higher engagement and sales.
