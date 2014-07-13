class CreateProfitStatementReports < ActiveRecord::Migration
  def change
    create_table :profit_statement_reports do |t|
      t.string :code
      t.string :name
      t.string :industry
      t.time :report_date  #报表日期
      t.float :gross_revenue #一、营业总收入
      t.float :operating_income #营业收入
      t.float :interest_income #利息收入
      t.float :earned_premium #已赚保费
      t.float :fee_and_commission_income #手续费及佣金收入
      t.float :real_estate_sales #房地产销售收入
      t.float :other_operating_revenue #其他业务收入
      t.float :total_operating_cost #二、营业总成本
      t.float :operating_cost #营业成本
      t.float :interest_expense #利息支出
      t.float :fee_and_commission_expenses #手续费及佣金支出
      t.float :real_estate_sales_cost #房地产销售成本
      t.float :research_development_expense #研发费用
      t.float :surrender_value #退保金
      t.float :net_payments_for_insurance_claims #赔付支出净额
      t.float :net_provision_for_insurance_contracts #提取保险合同准备金净额
      t.float :bond_insurance_expense #保单红利支出
      t.float :amortized_reinsurance_expenditures #分保费用
      t.float :other_operational_costs #其他业务成本
      t.float :business_tariff_and_annex #营业税金及附加
      t.float :sales_costs #销售费用
      t.float :management_cost #管理费用
      t.float :finance_charges #财务费用
      t.float :asset_impairment_loss #资产减值损失
      t.float :changes_in_the_fair_value_earnings #公允价值变动收益
      t.float :investment_income #投资收益
      t.float :associated_enterprises_and_joint_venture_investment_income#其中:对联营企业和合营企业的投资收益
      t.float :foreign_exchange_earnings#汇兑收益
      t.float :profit_and_loss_of_futures#期货损益
      t.float :managed_earnings#托管收益
      t.float :subsidize_revenue#补贴收入
      t.float :income_from_other_operation#其他业务利润
      t.float :operating_profit#三、营业利润
      t.float :non_operating_income#营业外收入
      t.float :nonbusiness_expenditure#营业外支出
      t.float :disposal_loss_on_noncurrent_liability#非流动资产处置损失
      t.float :total_Profits#利润总额
      t.float :income_tax_expenses#所得税费用
      t.float :unrealised_investment_losses#未确认投资损失
      t.float :net_profit#四、净利润
      t.float :net_profit_attributable_to_parent_company_owners#归属于母公司所有者的净利润
      t.float :minority_interests#少数股东损益
      t.float :earnings_per_share#五、每股收益
      t.float :basic_earnings_per_share_yuan#基本每股收益
      t.float :diluted_earnings_per_share_yuan#稀释每股收益
      t.float :oci#六、其他综合收益
      t.float :aggregate_comprehensive_income#七、综合收益总额
      t.float :total_comprehensive_income_attributable_to_parent_company_owners#归属于母公司所有者的综合收益总额
      t.float :total_comprehensive_income_attributable_to_minority_shareholders#归属于少数股东的综合收益总额
      t.timestamps
    end
    add_index :profit_statement_reports, [:code, :report_date], :unique => true

  end
end