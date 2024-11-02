<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson">
				<lxslt:script lang="javascript">
					<![CDATA[
					// Limited to 50 strings of Debugging
					var debugFeed = [];
					var debugFlag = false;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, convertedPrizeValues, prizeNamesDesc)
					{
						var scenario = getScenario(jsonContext);
						var gameData = scenario.split('|');
						var winningNos = gameData[0].split(',');
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var prizeValues = (convertedPrizeValues.substring(1)).split('|');
						
						//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
						// Print Translation Table to !DEBUG
						var index = 1;
						registerDebugText("Translation Table");
						while(index < translations.item(0).getChildNodes().getLength())
						{
							var childNode = translations.item(0).getChildNodes().item(index);
							registerDebugText(childNode.getAttribute("key") + ": " +  childNode.getAttribute("value"));
							index += 2;
						}
						
						// !DEBUG
						//registerDebugText("Translating the text \"softwareId\" to \"" + getTranslationByName("softwareId", translations) + "\"");
						///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					
						// Output winning numbers table.
						var r = [];
						var prizeText = '';

						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							r.push('<tr>');
								r.push('<td class="tablebody" style="padding-right:25px">');
									r.push(getTranslationByName("winningNumbers", translations));
								r.push('</td>');
								r.push('<td class="tablebody">');
									r.push(gameData[0]);
								r.push('</td>');
							r.push('</tr>');
						r.push('</table>');
						
						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							r.push('<tr>');
								r.push('<td class="tablebody">');
									r.push(getTranslationByName("scenarioDesc", translations));
								r.push('</td>');
							r.push('</tr>');
						r.push('</table>');

						var turnValues;
						var turnPrizes;
						var totals;
						// Wins Bonus Fuel
						var bonusFuelTurn = gameData[2] > 0;
						
						r.push('<br>');

						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
						r.push('<tr>');
							r.push('<td class="tablehead" style="padding-right:10px">'); 
								r.push(getTranslationByName("possScenarios", translations));
							r.push('</td>');
							for (location=1; location<6; location++)
							{
								r.push('<td class="tablehead" colspan="3" align="center">');
							 		r.push(getTranslationByName("scenario", translations) + ' ' + location);
						 		r.push('</td>');
							}
						r.push('</tr>');
						
						r.push('<tr>');
							r.push('<td class="tablehead" style="padding-right:10px">');
								r.push(getTranslationByName("basedOnLevels", translations));
							r.push('</td>');
							for (location=1; location<6; location++)
							{
								r.push('<td class="tablehead" colspan="3" align="center">');
							 		r.push(getTranslationByName("levelsDesc" + location, translations));
						 		r.push('</td>');
							}
						r.push('</tr>');

						r.push('<tr>');
							r.push('<td class="tablehead" style="padding-right:10px">');
								r.push(getTranslationByName("location", translations));
							r.push('</td>');
							for (location=1; location<6; location++)
							{
								r.push('<td class="tablehead" colspan="3" align="center">');
							 		r.push(getTranslationByName("location" + location, translations));
						 		r.push('</td>');	
							}
						r.push('</tr>');

						// turn data table headers
						r.push('<tr>');
							r.push('<td class="tablehead" style="padding-right:10px">');
								r.push(getTranslationByName("turnData", translations));
							r.push('</td>');
							for (location=1; location<6; location++)
							{
								r.push('<td class="tablehead" align="center" style="padding-right:10px">');
							 		r.push(getTranslationByName("number", translations));
						 		r.push('</td>');
								r.push('<td class="tablehead" align="right" style="padding-right:10px">');
							 		r.push(getTranslationByName("prize", translations));
						 		r.push('</td>');
								r.push('<td class="tablehead" align="center" style="padding-right:25px">');
							 		r.push(getTranslationByName("win", translations));
						 		r.push('</td>');
							}
						r.push('</tr>');

						// calculate required values
						turnValues = [];
						turnPrizes = [];
						for (location=1, totalIndex=-1; location<6; location++)
						{
							// Wins from turns
							turnValues[location] = getOutcomeData(gameData[location+2],0);
							turnPrizes[location] = getOutcomeData(gameData[location+2],1);
						}

						multipliers = [1,2,3,5,10];
						
						// display turn data
						var iwShown = [0,0,0,0,0];
						var iwShow = 0;
						for (turn=0; turn<17; turn++)
						{
							r.push('<tr>');
							r.push('<td class="tablehead">');
							r.push('</td>');
							for (location=1; location<6; location++)
							{	
								r.push('<td class="tablehead" align="center" style="padding-right:10px">');
									if ((turnValues[location][turn] == "W") || (turnValues[location][turn] == "X") ||
								        (turnValues[location][turn] == "Y") || (turnValues[location][turn] == "Z")) 
									{
										var turnLetterVal = turnValues[location][turn].charCodeAt(0) -'W'.charCodeAt(0);
										r.push("x" + multipliers[turnLetterVal+1]);
									}
									else
									{
										if ((turnValues[location][turn] == undefined) && (iwShown[location-1] == 0))
										{
											iwShown[location-1] = 1;
											iwShow = 1;
											r.push(getTranslationByName("instantWin", translations)); 
										}
										else
										{
											r.push(turnValues[location][turn]);
										}
									}
								r.push('</td>');
								r.push('<td class="tablehead" align="right" style="padding-right:10px">');
								if (iwShow == 1)
								{
									r.push(prizeValues[getPrizeNameIndex(prizeNames, "IW" + gameData[1])]);
								}
								else
								{
									r.push(prizeValues[getPrizeNameIndex(prizeNames, turnPrizes[location][turn])]);
								}
								r.push('</td>');
								r.push('<td class="tablehead" align="center" style="padding-right:25px">');
								if ((turnValues[location][turn] == winningNos[0]) || (turnValues[location][turn] == winningNos[1]) ||
							   		(turnValues[location][turn] == winningNos[2]) || (turnValues[location][turn] == winningNos[3]) ||
									(turnValues[location][turn] == "W") || (turnValues[location][turn] == "X") ||
									(turnValues[location][turn] == "Y") || (turnValues[location][turn] == "Z") ||
									(iwShow == 1))
								{
									if (iwShow == 1)
									{
										iwShow = 0;
										if (gameData[1] > 0)
										{
											r.push(getTranslationByName("wins", translations));
										}
										else
										{
											r.push(getTranslationByName("noWin", translations));
										}
									}
									else
									{
										r.push(getTranslationByName("wins", translations));
									}
								}
								r.push('</td>');
							}
							r.push('</tr>');
						}
						r.push('</table>');					

						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							r.push('<tr>');
								r.push('<td class="tablebody">');
									r.push(getTranslationByName("bonusFuel", translations) + " : " + bonusFuelTurn);
								r.push('</td>');
							r.push('</tr>');
						r.push('</table>');								
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
							{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
								r.push('</td>');
								r.push('</tr>');
							}
							r.push('</table>');
						}

						return r.join('');
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["8", "35", "4", "13", ...] or ["E", "E", "D", "G", ...]
					function getOutcomeData(turndata, index)
					{
						var outcomePairs = turndata.split(",");
						var result = [];
						for(var i = 0; i < outcomePairs.length; ++i)
						{
							result.push(outcomePairs[i].split(":")[index]);
						}
						return result;
					}

					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}

					function getPrizeAsFloat(prize)
					{
						var prizeFloat = parseFloat(prize.replace(/[^0-9-.]/g, ''));
						return prizeFloat;
					}

					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							index += 1;
						}
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>

				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>

				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
