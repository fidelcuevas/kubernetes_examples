select 
	ohlc.ticker, 
	ohlc.date, 
	ohlc.closeadj, 
    fundamental.accoci,
    fundamental.assets,
    fundamental.assetsc,
    fundamental.assetsnc,
    fundamental.bvps,
    fundamental.capex,
    fundamental.cashneq,
    fundamental.cashnequsd,
    fundamental.cor,
    fundamental.consolinc,
    fundamental.currentratio,
    fundamental.de,
    fundamental.debt,
    fundamental.debtc,
    fundamental.debtnc,
    fundamental.debtusd,
    fundamental.deferredrev,
    fundamental.depamor,
    fundamental.deposits,
    fundamental.divyield,
    fundamental.dps,
    fundamental.ebit,
    fundamental.ebitda,
    fundamental.ebitdamargin,
    fundamental.ebitdausd,
    fundamental.ebitusd,
    fundamental.ebt,
    fundamental.eps,
    fundamental.epsdil,
    fundamental.epsusd,
    fundamental.equity,
    fundamental.equityusd,
    fundamental.ev,
    fundamental.evebit,
    fundamental.evebitda,
    fundamental.fcf,
    fundamental.fcfps,
    fundamental.fxusd,
    fundamental.gp,
    fundamental.grossmargin,
    fundamental.intangibles,
    fundamental.intexp,
    fundamental.invcap,
    fundamental.inventory,
    fundamental.investments,
    fundamental.investmentsc,
    fundamental.investmentsnc,
    fundamental.liabilities,
    fundamental.liabilitiesc,
    fundamental.liabilitiesnc,
    fundamental.ncf,
    fundamental.ncfbus,
    fundamental.ncfcommon,
    fundamental.ncfdebt,
    fundamental.ncfdiv,
    fundamental.ncff,
    fundamental.ncfi,
    fundamental.ncfinv,
    fundamental.ncfo,
    fundamental.ncfx,
    fundamental.netinc,
    fundamental.netinccmn,
    fundamental.netinccmnusd,
    fundamental.netincdis,
    fundamental.netincnci,
    fundamental.netmargin,
    fundamental.opex,
    fundamental.opinc,
    fundamental.payables,
    fundamental.payoutratio,
    fundamental.ppnenet,
    fundamental.prefdivis,
    fundamental.receivables,
    fundamental.retearn,
    fundamental.revenue,
    fundamental.revenueusd,
    fundamental.rnd,
    fundamental.sbcomp,
    fundamental.sgna,
    fundamental.sharefactor,
    fundamental.sharesbas,
    fundamental.shareswa,
    fundamental.shareswadil,
    fundamental.sps,
    fundamental.tangibles,
    fundamental.taxassets,
    fundamental.taxexp,
    fundamental.taxliabilities,
    fundamental.tbvps,
    fundamental.workingcapital
from sharadar.ohlc ohlc left outer join sharadar.fundamental fundamental
on ohlc.ticker = fundamental.ticker and ohlc.date = fundamental.datekey
