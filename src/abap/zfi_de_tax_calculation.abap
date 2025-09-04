REPORT zfi_de_tax_calculation.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  PARAMETERS:
    p_revenu TYPE zfi_de_amount,
    p_expens TYPE zfi_de_amount.
SELECTION-SCREEN: END OF BLOCK b1.

START-OF-SELECTION.
  " Process the BRF+ function and capture the result
  DATA(lv_result) =
    zcl_process_brf_app=>get_instance(
      EXPORTING iv_func_id = 'DD80909B95BA1FE0A2A90543E4A18A7B' )->process(
        EXPORTING
          iv_total_revenue = p_revenu
          iv_total_expense = p_expens ).

END-OF-SELECTION.

WRITE: /10 'German Tax Calculation'.
SKIP.
WRITE: /10 'Total Revenue:',   35 p_revenu,                      55 'Total Revenue'.
WRITE: /10 'Total Expense:',   35 p_expens,                      55 'Total Expenses'.
SKIP.
WRITE: /10 'Total VAT:',               35 lv_result-zfi_vat_amount,              55 '19% of Total Revenue'.
WRITE: /10 'Taxable Profit:',          35 lv_result-zfi_taxable_profit,          55 'Total Revenue - VAT Amount'.
WRITE: /10 'Corporate Tax:',           35 lv_result-zfi_corporate_tax,           55 '15% of Taxable Profit'.
WRITE: /10 'Solidarity Surcharge:',    35 lv_result-zfi_solidarity_surcharge,    55 '5.5% of Corporate Tax'.
WRITE: /10 'Trade Tax:',               35 lv_result-zfi_trade_tax,               55 '14% of Taxable Profit'.
