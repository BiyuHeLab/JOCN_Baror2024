
function SP_varExplained ( data )

[~,~,~,~,explained] = pca(dataEEG_ICA.trial{1});
figure
plot(cumsum(explained));
xlabel('component')
ylabel('cumulative % variance explained')